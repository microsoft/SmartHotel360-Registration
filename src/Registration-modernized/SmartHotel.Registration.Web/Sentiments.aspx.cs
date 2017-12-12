using System;
using System.Net.Http;
using System.Web.UI.WebControls;
using SmartHotel.Model;
using Newtonsoft.Json;
using System.Net.Http.Headers;
using System.Web.UI;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.HtmlControls;

namespace SmartHotel.Registration
{
    public partial class _Sentiments : Page
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
                return;

            using (var client = new HttpClient())
            {
                var hostIp = Environment.GetEnvironmentVariable("Fabric_NodeIPOrFQDN");

                client.BaseAddress = new Uri($"http://{hostIp}:19081/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                var JsonSentiments = "";

                HttpResponseMessage response = await client.GetAsync("SmartHotel.RegistrationApp/SentimentIntegration/api/values");
                if (response.IsSuccessStatusCode)
                {
                    JsonSentiments = await response.Content.ReadAsStringAsync();
                }

                var sentiments = JsonConvert.DeserializeObject<List<Tweet>>(JsonSentiments);

                RegistrationGrid.DataSource = sentiments;
                RegistrationGrid.DataBind();

                var sentimentControl = Page.Master.FindControl("Sentiments") as HtmlGenericControl;
                sentimentControl.InnerText = sentiments.Count.ToString();
            }
        }
        
        protected void SentimentGrid_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                ColorSentimentCell(e);
                ExtractHashTags(e);
            }
        }

        private void ExtractHashTags(GridViewRowEventArgs e)
        {
            Tweet tweet = (Tweet)e.Row.DataItem;
            string hashtagCellText = string.Empty;

            foreach (string hashtag in tweet.Hashtags)
            {
                hashtagCellText += $"{hashtag}" + " ";
            }
            e.Row.Cells[2].Text = hashtagCellText;

        }

        private void ColorSentimentCell(GridViewRowEventArgs e)
        {
            var color = CheckSentiment(e.Row.Cells[1].Text);

            switch (color)
            {
                case "red":
                    e.Row.Cells[1].BackColor = System.Drawing.Color.Red;
                    e.Row.Cells[1].ForeColor = System.Drawing.Color.White;
                    break;
                case "green":
                    e.Row.Cells[1].BackColor = System.Drawing.Color.Green;
                    e.Row.Cells[1].ForeColor = System.Drawing.Color.White;
                    break;
                default:
                    break;
            }
        }

        private string CheckSentiment(string sentimentScore)
        {

            if (Double.Parse(sentimentScore.Substring(0, 3)) > 60)
            {
                return "green";
            }
            if (Double.Parse(sentimentScore.Substring(0, 3)) < 40)
            {
                return "red";
            }
            else
            {
                return "";
            }
        }
    }
}