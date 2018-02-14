using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Documents;
using Microsoft.Azure.Documents.Client;
using Microsoft.Azure.Documents.Linq;
using SentimentIntegration.Model;

namespace SentimentIntegration.Controllers
{
    [Route("api/[controller]")]
    public class ValuesController : Controller
    {
        private static DocumentClient client;
        private string DocDBEndpoint = Environment.GetEnvironmentVariable("CosmosDBEndpoint");
        private string DocDBAuthKey = Environment.GetEnvironmentVariable("CosmosDBAuthKey");

        public ValuesController()
        {
            if (!string.IsNullOrEmpty(DocDBEndpoint) && !string.IsNullOrEmpty(DocDBAuthKey))
            {
                client = new DocumentClient(new Uri(DocDBEndpoint), DocDBAuthKey);
            }
        }

        // GET api/values
        [HttpGet]
        public async Task<ActionResult> Get()
        {
            List<Tweet> tweets = new List<Tweet>();

            if (client != null)
            {
                tweets = await GetItemsAsync(d => d.Sentiment != -1);
            }
            else
            {
                tweets.Add(new Tweet
                {
                    Id = "2ed5e734-8034-bf3a-ac85-705b7713d223",
                    TweetID = 927750234331580100,
                    TweetUrl = new Uri("https://twitter.com/status/927750237331580100"),
                    UserName = "CoreySandersWA",
                    UserAlias = "@CoreySandersWA",
                    Text = "I can write forever and ever about the great @SmartHotel",
                    Language = "en",
                    Sentiment = 0.75
                });
            }

            return Json(tweets);
        }

        public static async Task<List<Tweet>> GetItemsAsync(Expression<Func<Tweet, bool>> predicate)
        {
            var databaseId = "Tweets";
            var collectionId = "Tweets";

            IDocumentQuery<Tweet> query = client.CreateDocumentQuery<Tweet>(
                    UriFactory.CreateDocumentCollectionUri(databaseId, collectionId),
                    new FeedOptions { MaxItemCount = -1, EnableCrossPartitionQuery = true })
                    .Where(predicate)
                    .AsDocumentQuery();

            List<Tweet> results = new List<Tweet>();
            while (query.HasMoreResults)
            {
                results.AddRange(await query.ExecuteNextAsync<Tweet>());
            }

            return results;
        }

    }

}
