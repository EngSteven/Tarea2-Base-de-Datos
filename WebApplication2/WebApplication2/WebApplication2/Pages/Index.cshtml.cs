using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using WebApplication2.Pages.Clientes;

namespace WebApplication2.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;

        public IndexModel(ILogger<IndexModel> logger)
        {
            _logger = logger;
        }

        public List<ClienteInfo> listaClientes = new List<ClienteInfo>();

        public void OnGet()
        {
            try
            {
                String connectionString = "Data Source=project0-server.database.windows.net;Initial Catalog=project0-database;Persist Security Info=True;User ID=stevensql;Password=Killua36911-";

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    String sql = "SELECT * FROM Articulo";
                    using (SqlCommand command = new SqlCommand(sql, connection))
                    {
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                ClienteInfo clienteInfo = new ClienteInfo();
                                clienteInfo.id = "" + reader.GetInt32(0);
                                clienteInfo.Nombre = reader.GetString(1);
                                clienteInfo.Precio = "" + reader.GetSqlMoney(2);
                                //clienteInfo.created_at = reader.GetDateTime(3).ToString();

                                listaClientes.Add(clienteInfo);

                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception: " + ex.ToString());
            }
        }
    }
    public class ClienteInfo
    {
        public String id;
        public String Nombre;
        public String Precio;
        //public String created_at;

    }
}