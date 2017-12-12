using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using System.Collections.Generic;
using Microsoft.Azure.Documents;
using Microsoft.Azure.CognitiveServices.Language.TextAnalytics;
using Microsoft.Azure.CognitiveServices.Language.TextAnalytics.Models;
using System;
using System.Configuration;
using System.Linq;
using SmartHotel360.AzureFunction.Model;
using Newtonsoft.Json;
using System.Threading.Tasks;
using Microsoft.Azure.Documents.Client;

namespace SmartHotel360.AzureFunction
{
    public static class CosmosDBTriggerFunction
    {
        [FunctionName("CosmosDBTriggerFunction")]
        public static async Task RunAsync(
            [CosmosDBTrigger("Tweets", "TweetsToAnalyze", CreateLeaseCollectionIfNotExists = true, LeasesCollectionThroughput = 1000)]
            IReadOnlyList<Document> documents, TraceWriter log)
        {
            var textAnalyticsAzureRegion = ConfigurationManager.AppSettings["AnalyticsAzureRegion"];
            var textAnalyticsSubKey = ConfigurationManager.AppSettings["AnalyticsSubKey"];
            var databaseName = ConfigurationManager.AppSettings["CosmosDatabase"];
            var outputCollectionName = ConfigurationManager.AppSettings["CosmosCollectionOutput"];
            var inputCollectionName = ConfigurationManager.AppSettings["CosmosCollectionInput"];
            var endpoint = ConfigurationManager.AppSettings["CosmosEndpoint"];
            var authKey = ConfigurationManager.AppSettings["CosmosKey"];
            var tweetsList = new List<Tweet>();
            var scoredDocuments = new List<object>();

            log.Info($"Function triggered, processing {documents.Count} documents.");

            //Create list of Tweets
            foreach (var doc in documents)
            {
                Tweet tweet = (dynamic)doc;
                tweetsList.Add(tweet);
            }

            // Do TextAnalysis
            using (ITextAnalyticsAPI textAnalyzerClient = new TextAnalyticsAPI())
            {
                AzureRegions region = (AzureRegions)Enum.Parse(typeof(AzureRegions), textAnalyticsAzureRegion);
                textAnalyzerClient.AzureRegion = region;
                textAnalyzerClient.SubscriptionKey = textAnalyticsSubKey;

                // Add tweets to analysis batch
                var mlinput = new List<MultiLanguageInput>();
                foreach (var doc in documents)
                {
                    Tweet tweet = JsonConvert.DeserializeObject<Tweet>(doc.ToString());
                    mlinput.Add(new MultiLanguageInput(tweet.Language, tweet.Id, tweet.Text));
                }
                var mlbatchinput = new MultiLanguageBatchInput(mlinput);

                SentimentBatchResult result = textAnalyzerClient.Sentiment(mlbatchinput);

                // Add score to the original tweets and convert to documents
                foreach (var document in result.Documents)
                {
                    var tweet = tweetsList
                        .Where(d => d.Id == document.Id)
                        .FirstOrDefault()
                        .Sentiment = document.Score;

                    scoredDocuments.Add(JsonConvert.SerializeObject(tweet));
                }
            }

            var outputCollectionLink = UriFactory.CreateDocumentCollectionUri(databaseName, outputCollectionName);

            using (DocumentClient cosmosClient = new DocumentClient(
                new Uri(endpoint), authKey,
                new ConnectionPolicy { ConnectionMode = ConnectionMode.Direct, ConnectionProtocol = Protocol.Tcp }))
            {
                foreach (var scoredTweet in tweetsList)
                {
                    await cosmosClient.CreateDocumentAsync(outputCollectionLink, scoredTweet);
                    await cosmosClient.DeleteDocumentAsync(UriFactory.CreateDocumentUri(databaseName, inputCollectionName, scoredTweet.Id));
                }
            }
        }
    }
}
