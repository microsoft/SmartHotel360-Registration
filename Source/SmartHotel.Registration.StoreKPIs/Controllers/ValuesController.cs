namespace SmartHotel.Registration.StoreKPIs.Controllers
{
    using System;
    using System.Collections.Generic;
    using System.Fabric;
    using System.Threading;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.ServiceFabric.Data;
    using Microsoft.ServiceFabric.Data.Collections;
    using SmartHotel.Registration.StoreKPIs.Models;

    [Route("api/[controller]")]
    public class ValuesController : Controller
    {
        private static readonly Uri ValuesDictionaryName = new Uri("store:/values");
        private readonly IReliableStateManager _stateManager;

        public ValuesController(IReliableStateManager stateManager)
        {
            _stateManager = stateManager;
        }

        // GET api/values
        [HttpGet]
        public async Task<IActionResult> Get()
        {
            try
            {
                var result = new List<KeyValuePair<string, BookingAggregates>>();

                var tryGetResult = await _stateManager.TryGetAsync<IReliableDictionary<string, BookingAggregates>>(ValuesDictionaryName);

                if (tryGetResult.HasValue)
                {
                    IReliableDictionary<string, BookingAggregates> dictionary = tryGetResult.Value;

                    using (ITransaction tx = _stateManager.CreateTransaction())
                    {
                        var list = await dictionary.CreateEnumerableAsync(tx);
                        var enumerator = list.GetAsyncEnumerator();

                        while (await enumerator.MoveNextAsync(CancellationToken.None))
                        {
                            result.Add(enumerator.Current);
                        }
                    }
                }
                return Json(result);
            }
            catch (FabricException)
            {
                return new ContentResult { StatusCode = 503, Content = "The service was unable to process the request. Please try again." };
            }
        }

        // GET api/values/5
        [HttpGet("{id}")]
        public async Task<IActionResult> Get(string id)
        {
            try
            {
                var dictionary = await _stateManager.GetOrAddAsync<IReliableDictionary<string, BookingAggregates>>(ValuesDictionaryName);

                using (ITransaction tx = _stateManager.CreateTransaction())
                {
                    var result = await dictionary.TryGetValueAsync(tx, id);

                    if (result.HasValue)
                    {
                        return Ok(result.Value);
                    }

                    return NotFound();
                }
            }
            catch (FabricNotPrimaryException)
            {
                return new ContentResult { StatusCode = 410, Content = "The primary replica has moved. Please re-resolve the service." };
            }
            catch (FabricException)
            {
                return new ContentResult { StatusCode = 503, Content = "The service was unable to process the request. Please try again." };
            }
        }

        // POST api/values
        [HttpPost]
        public async Task<IActionResult> Post(string key, [FromBody] Booking booking)
        {
            try
            {
                var dictionary = await _stateManager.GetOrAddAsync<IReliableDictionary<string, BookingAggregates>>(ValuesDictionaryName);
                var bookingAggregates = await GetBookingAggregatesByKey(key);
                
                using (ITransaction tx = _stateManager.CreateTransaction())
                {
                    if (bookingAggregates == null)
                    {
                        bookingAggregates = new BookingAggregates(booking);                        
                    }
                    else
                    {
                        bookingAggregates.Update(booking);
                    }

                    await dictionary.SetAsync(tx, key, bookingAggregates);
                    await tx.CommitAsync();
                }

                return Ok();
            }
            catch (FabricNotPrimaryException)
            {
                return new ContentResult { StatusCode = 410, Content = "The primary replica has moved. Please re-resolve the service." };
            }
            catch (FabricException)
            {
                return new ContentResult { StatusCode = 503, Content = "The service was unable to process the request. Please try again." };
            }
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string key)
        {
            var dictionary = await _stateManager.GetOrAddAsync<IReliableDictionary<string, BookingAggregates>>(ValuesDictionaryName);

            try
            {
                using (ITransaction tx = _stateManager.CreateTransaction())
                {
                    var result = await dictionary.TryRemoveAsync(tx, key);

                    await tx.CommitAsync();

                    if (result.HasValue)
                    {
                        return Ok();
                    }

                    return new ContentResult { StatusCode = 400, Content = $"A value with name {key} doesn't exist." };
                }
            }
            catch (FabricNotPrimaryException)
            {
                return new ContentResult { StatusCode = 503, Content = "The primary replica has moved. Please re-resolve the service." };
            }
        }

        private async Task<BookingAggregates> GetBookingAggregatesByKey(string key)
        {
            var dictionary = await _stateManager.GetOrAddAsync<IReliableDictionary<string, BookingAggregates>>(ValuesDictionaryName);

            using (ITransaction tx = _stateManager.CreateTransaction())
            {
                var result = await dictionary.TryGetValueAsync(tx, key);

                return result.HasValue ? result.Value : null;               
            }
        }
    }
}
