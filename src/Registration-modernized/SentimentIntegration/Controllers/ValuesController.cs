using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SentimentIntegration.Model;

namespace SentimentIntegration.Controllers
{
    [Route("api/[controller]")]
    public class ValuesController : Controller
    {
        // GET api/values
        [HttpGet]
        public async Task<ActionResult> Get()
        {
            var tweets = await DocumentDBRepository<Tweet>.GetItemsAsync(d => d.Sentiment != -1);

            return Json(tweets);
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "value";
        }

        // POST api/values
        [HttpPost]
        public void Post([FromBody]string value)
        {
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
