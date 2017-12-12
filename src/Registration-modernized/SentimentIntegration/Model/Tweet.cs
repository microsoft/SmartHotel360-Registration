using System;
using System.Collections.Generic;

namespace SentimentIntegration.Model
{
    public class Tweet
    {
        public string Id { get; set; }
        public Int64 TweetID { get; set; }
        public Uri TweetUrl { get; set; }
        public string UserName { get; set; }
        public string UserAlias { get; set; }
        public Uri UserPictureUrl { get; set; }
        public string Text { get; set; }
        public string Language { get; set; }
        public double? Sentiment { get; set; }
        public int Retweet_count { get; set; }
        public int Followers { get; set; }
        public List<string> Hashtags { get; set; }
    }
}
