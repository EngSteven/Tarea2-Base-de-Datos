using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using WebApplication2.Pages.Clientes;

namespace WebApplication2.Pages
{
    public class PricipalModel : PageModel
    {
        public String cantidad = "";
        public String nombre = "";
        public String clase = "";
        public String errorMessage = "";      //Variable para los mensajes de error
        private readonly ILogger<IndexModel> _logger;
        public List<ClaseArticulo> listaClaseArticulos1 = new List<ClaseArticulo>();
        public ArticuloInfo articulo1 = new ArticuloInfo();

        public PricipalModel(ILogger<IndexModel> logger)
        {
            _logger = logger;
        }

        //public List<ClienteInfo> listaArticulos = new List<ClienteInfo>();
        public List<ArticuloInfo> listaArticulos = new List<ArticuloInfo>();

        public void OnGet()
        {
            try
            {
                String connectionString = "Data Source=project0-server.database.windows.net;Initial Catalog=project0-database;Persist Security Info=True;User ID=stevensql;Password=Killua36911-";

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();                                      //Se abre la coneccion con la BD.
                    using (SqlCommand command = new SqlCommand("dbo.ListaArticulos", connection))
                    //using (SqlCommand command = new SqlCommand("dbo.FiltrarCantidad", connection))
                    {
                        //Variables para obtener el DataSet mandados de la BD.
                        SqlDataAdapter adapter = new SqlDataAdapter();
                        DataTable table = new DataTable();

                        command.CommandType = CommandType.StoredProcedure;  //Indicar que el comando sera un SP.
                                                                            //Codigo para que detecte el output del SP.
                                                                            //command.Parameters.AddWithValue("@inCantidad", cantidad);
                        SqlParameter resultCodeParam = new SqlParameter("@outResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(resultCodeParam);
                        command.ExecuteNonQuery();
                        //Porceso de obtener el DataSet.
                        adapter.SelectCommand = command;
                        DataSet dataSet = new DataSet();
                        adapter.Fill(dataSet);

                        //Si el output de errores por DataSet es 0 (No hay problemas).
                        if (dataSet.Tables[0].Rows[0][0].ToString().Equals("0"))
                        {
                            foreach (DataRow row in dataSet.Tables[1].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                ArticuloInfo articuloInfo = new ArticuloInfo();
                                articuloInfo.Codigo = "" + row[0];
                                articuloInfo.Nombre = "" + row[1];
                                articuloInfo.Clase = "" + row[2];
                                articuloInfo.Precio = "" + SqlMoney.Parse(row[3].ToString());

                                listaArticulos.Add(articuloInfo);             //A�adir cada fila al array para su visualizacion.
                            }
                            foreach (DataRow row in dataSet.Tables[2].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                ClaseArticulo claseArticulo = new ClaseArticulo();

                                claseArticulo.Nombre = "" + row[0];

                                listaClaseArticulos1.Add(claseArticulo);             //A?adir cada fila al array para su visualizacion.
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


        public async Task OnPostCantidad()
        {
            try
            {
                cantidad = Request.Form["Cantidad"];
                articulo1 = new ArticuloInfo();
                String connectionString = "Data Source=project0-server.database.windows.net;Initial Catalog=project0-database;Persist Security Info=True;User ID=stevensql;Password=Killua36911-";

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();                                      //Se abre la coneccion con la BD.
                    using (SqlCommand command = new SqlCommand("dbo.FiltrarCantidad", connection))
                    {
                        //Variables para obtener el DataSet mandados de la BD.
                        SqlDataAdapter adapter = new SqlDataAdapter();
                        DataTable table = new DataTable();

                        command.CommandType = CommandType.StoredProcedure;  //Indicar que el comando sera un SP.
                                                                            //Codigo para que detecte el output del SP.
                        Console.WriteLine(cantidad);
                        command.Parameters.AddWithValue("@inCantidad", SqlInt16.Parse(cantidad));
                        SqlParameter resultCodeParam = new SqlParameter("@outResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(resultCodeParam);

                        //command.ExecuteNonQuery();
                        //Porceso de obtener el DataSet.
                        adapter.SelectCommand = command;
                        DataSet dataSet = new DataSet();
                        adapter.Fill(dataSet);



                        //Si el output de errores por DataSet es 0 (No hay problemas).
                        if (dataSet.Tables[0].Rows[0][0].ToString().Equals("0"))
                        {
                            foreach (DataRow row in dataSet.Tables[1].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                ArticuloInfo articuloInfo = new ArticuloInfo();
                                articuloInfo.Codigo = "" + row[0];
                                articuloInfo.Nombre = "" + row[1];
                                articuloInfo.Clase = "" + row[2];
                                articuloInfo.Precio = "" + SqlMoney.Parse(row[3].ToString());

                                listaArticulos.Add(articuloInfo);             //A�adir cada fila al array para su visualizacion.
                            }
                            foreach (DataRow row in dataSet.Tables[2].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                ClaseArticulo claseArticulo = new ClaseArticulo();

                                claseArticulo.Nombre = "" + row[0];
                                Console.WriteLine("Exception: ---" + claseArticulo.Nombre + "------");
                                listaClaseArticulos1.Add(claseArticulo);             //A?adir cada fila al array para su visualizacion.
                            }
                        }
                        else
                        {
                            //En caso de que haya algun error al cargar la tabla de articulos.
                            errorMessage = "Error al buscar por cantidad en la lista de articulos.";
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

        public async Task OnPostNombre()
        {
            try
            {
                nombre = Request.Form["Nombre"];
                articulo1 = new ArticuloInfo();
                String connectionString = "Data Source=project0-server.database.windows.net;Initial Catalog=project0-database;Persist Security Info=True;User ID=stevensql;Password=Killua36911-";

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();                                      //Se abre la coneccion con la BD.
                    using (SqlCommand command = new SqlCommand("dbo.FiltrarNombre", connection))
                    {
                        //Variables para obtener el DataSet mandados de la BD.
                        SqlDataAdapter adapter = new SqlDataAdapter();
                        DataTable table = new DataTable();

                        command.CommandType = CommandType.StoredProcedure;  //Indicar que el comando sera un SP.
                                                                            //Codigo para que detecte el output del SP.
                        Console.WriteLine(cantidad);
                        command.Parameters.AddWithValue("@inNombre", nombre);
                        SqlParameter resultCodeParam = new SqlParameter("@outResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(resultCodeParam);

                        //command.ExecuteNonQuery();
                        //Porceso de obtener el DataSet.
                        adapter.SelectCommand = command;
                        DataSet dataSet = new DataSet();
                        adapter.Fill(dataSet);



                        //Si el output de errores por DataSet es 0 (No hay problemas).
                        if (dataSet.Tables[0].Rows[0][0].ToString().Equals("0"))
                        {
                            foreach (DataRow row in dataSet.Tables[1].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                ArticuloInfo articuloInfo = new ArticuloInfo();
                                articuloInfo.Codigo = "" + row[0];
                                articuloInfo.Nombre = "" + row[1];
                                articuloInfo.Clase = "" + row[2];
                                articuloInfo.Precio = "" + SqlMoney.Parse(row[3].ToString());

                                listaArticulos.Add(articuloInfo);             //A�adir cada fila al array para su visualizacion.
                            }
                            foreach (DataRow row in dataSet.Tables[2].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                ClaseArticulo claseArticulo = new ClaseArticulo();

                                claseArticulo.Nombre = "" + row[0];
                                Console.WriteLine("Exception: ---" + claseArticulo.Nombre + "------");
                                listaClaseArticulos1.Add(claseArticulo);             //A?adir cada fila al array para su visualizacion.
                            }
                        }
                        else
                        {
                            //En caso de que haya algun error al cargar la tabla de articulos.
                            errorMessage = "Error al buscar por cantidad en la lista de articulos.";
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
        public void OnPost()
        {
            try
            {
                clase = Request.Form["456"];
                articulo1 = new ArticuloInfo();
                String connectionString = "Data Source=project0-server.database.windows.net;Initial Catalog=project0-database;Persist Security Info=True;User ID=stevensql;Password=Killua36911-";

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();                                      //Se abre la coneccion con la BD.
                    using (SqlCommand command = new SqlCommand("dbo.FiltrarClase", connection))
                    {
                        //Variables para obtener el DataSet mandados de la BD.
                        SqlDataAdapter adapter = new SqlDataAdapter();
                        DataTable table = new DataTable();

                        command.CommandType = CommandType.StoredProcedure;  //Indicar que el comando sera un SP.
                                                                            //Codigo para que detecte el output del SP.
                        Console.WriteLine("-" + clase + "-");
                        command.Parameters.AddWithValue("@inClase", clase);
                        SqlParameter resultCodeParam = new SqlParameter("@outResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(resultCodeParam);

                        //command.ExecuteNonQuery();
                        //Porceso de obtener el DataSet.
                        adapter.SelectCommand = command;
                        DataSet dataSet = new DataSet();
                        adapter.Fill(dataSet);



                        //Si el output de errores por DataSet es 0 (No hay problemas).
                        if (dataSet.Tables[0].Rows[0][0].ToString().Equals("0"))
                        {
                            foreach (DataRow row in dataSet.Tables[1].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                ArticuloInfo articuloInfo = new ArticuloInfo();
                                articuloInfo.Codigo = "" + row[0];
                                articuloInfo.Nombre = "" + row[1];
                                articuloInfo.Clase = "" + row[2];
                                articuloInfo.Precio = "" + SqlMoney.Parse(row[3].ToString());

                                listaArticulos.Add(articuloInfo);             //A�adir cada fila al array para su visualizacion.
                            }
                            foreach (DataRow row in dataSet.Tables[2].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                ClaseArticulo claseArticulo = new ClaseArticulo();

                                claseArticulo.Nombre = "" + row[0];
                                Console.WriteLine("Exception: ---" + claseArticulo.Nombre + "------");
                                listaClaseArticulos1.Add(claseArticulo);             //A?adir cada fila al array para su visualizacion.
                            }
                        }
                        else
                        {
                            //En caso de que haya algun error al cargar la tabla de articulos.
                            errorMessage = "Error al buscar por cantidad en la lista de articulos.";
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
    public class ArticuloInfo                                                //Clase que equivaldra a las filas de la tabla para si manipulacion.
    {
        public String Codigo;
        public String Nombre;
        public String Clase;
        public String Precio;
    }
    public class ClaseArticulo                                                //Clase que equivaldra a las filas de la tabla para si manipulacion.
    {
        public String Nombre;
    }
}