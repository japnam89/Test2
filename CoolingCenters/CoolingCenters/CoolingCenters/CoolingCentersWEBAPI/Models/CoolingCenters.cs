using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace CoolingCentersWEBAPI.Models
{
    public class CoolingCenters
    {
        public string Address { get; set; }
        public string Lat { get; set; }
        public string Lon { get; set; }
    }

    public class CoolingCentersDAL
    {
        SqlConnection con;
        SqlCommand cmd;
        SqlParameter sprm = new SqlParameter();

        public CoolingCentersDAL()
        {
            con = new SqlConnection();
            cmd = new SqlCommand();
            string cnstr = ConfigurationManager.ConnectionStrings["cnStr"].ConnectionString;
            con.ConnectionString = cnstr;
            cmd.Connection = con;
        }

        public List<CoolingCenters> GetCoolingCenters()
        {
            List<CoolingCenters> lst = new List<CoolingCenters>();
            SqlDataReader dr;
            try
            {
                cmd.CommandText = "GetCoolingCenters";
                cmd.CommandType = CommandType.StoredProcedure;
                con.Open();

                dr = cmd.ExecuteReader();
                if (dr.HasRows)
                {
                    while (dr.Read())
                    {
                        CoolingCenters obj = new CoolingCenters();
                        obj.Address = dr.GetString(dr.GetOrdinal("Address"));
                        obj.Lat = dr.GetString(dr.GetOrdinal("Lat"));
                        obj.Lon = dr.GetString(dr.GetOrdinal("Lon"));
                        lst.Add(obj);
                    }
                }
                dr.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                cmd.Parameters.Clear();
                cmd.Dispose();
                con.Dispose();
                con.Close();
            }
            return lst;
        }
    }
}