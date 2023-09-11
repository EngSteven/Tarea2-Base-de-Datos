using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using WebApplication2.Pages.Clientes;

namespace WebApplication2.Pages
{
    public class IndexModel : PageModel
    {
        public String errorMessage = "";                                    //Variable para los mensajes de error
        private readonly ILogger<IndexModel> _logger;

        public IndexModel(ILogger<IndexModel> logger)
        {
            _logger = logger;
        }

        public List<ClienteInfo> listaArticulos = new List<ClienteInfo>();

        public void OnGet()
        {
            try
            {
                String connectionString = "Data Source=project0-server.database.windows.net;Initial Catalog=project0-database;Persist Security Info=True;User ID=stevensql;Password=Killua36911-";

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();                                      //Se abre la coneccion con la BD.
                    using (SqlCommand command = new SqlCommand("dbo.ListaDeArticulos2", connection))
                    {
                        //Variables para obtener el DataSet mandados de la BD.
                        SqlDataAdapter adapter = new SqlDataAdapter();
                        DataTable table = new DataTable();

                        command.CommandType = CommandType.StoredProcedure;  //Indicar que el comando sera un SP.
                                                                            //Codigo para que detecte el output del SP.
                        SqlParameter resultCodeParam = new SqlParameter("@outResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(resultCodeParam);

                        //Porceso de obtener el DataSet.
                        adapter.SelectCommand = command;
                        DataSet dataSet = new DataSet();
                        adapter.Fill(dataSet);

                        //Si el output de errores por DataSet es 0 (No hay problemas).
                        if (dataSet.Tables[0].Rows[0][0].ToString().Equals("0"))
                        {
                            foreach (DataRow row in dataSet.Tables[1].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                ClienteInfo clienteInfo = new ClienteInfo();
                                clienteInfo.id = "" + row[0];
                                clienteInfo.Nombre = "" + row[1];
                                clienteInfo.Precio = "" + SqlMoney.Parse(row[2].ToString());

                                listaArticulos.Add(clienteInfo);             //Añadir cada fila al array para su visualizacion.
                            }
                        }
                        else
                        {
                            //En caso de que haya algun error al cargar la tabla de articulos.
                            errorMessage = "Error al cargar la lista de articulos.";
                            return;
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
    public class ClienteInfo                                                //Clase que equivaldra a las filas de la tabla para si manipulacion.
    {
        public String id;
        public String Nombre;
        public String Precio;
    }
}