using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using CoolingCentersWEBAPI.Models;

namespace CoolingCentersWEBAPI.Controllers
{
    public class CSController : ApiController
    {
        [HttpGet]
        public IEnumerable<CoolingCenters> GetCoolingCenters()
        {
            CoolingCentersDAL obj = new CoolingCentersDAL();
            IEnumerable<CoolingCenters> lst = obj.GetCoolingCenters();
            if (lst == null)
            {
                throw new HttpResponseException(Request.CreateErrorResponse(HttpStatusCode.NotFound, "No record(s) found."));
            }
            else
            {
                return lst;
            }
        }
    }
}
