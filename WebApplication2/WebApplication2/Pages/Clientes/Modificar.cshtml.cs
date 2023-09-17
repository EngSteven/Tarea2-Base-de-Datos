using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using WebApplication2.Pages.Clientes;

namespace WebApplication2.Pages.Clientes
{
    public class ModificarModel : PageModel
    {
        
        public List<ClaseArticulo> listaClaseArticulos = new List<ClaseArticulo>();
        public String codigoIngresado = "";
        public String errorMessage = "";                                    //Variable para los mensajes de error
        public String successMessage = "";
        public ArticuloInfo articulo = new ArticuloInfo();
        public int idArticulo = 0;
        public String clase = "";

        public void OnGet()
        {
            try
            {
                codigoIngresado = TempData["CodigoIngresado"] as string;
                Console.WriteLine(codigoIngresado);
                String SPNombre = "dbo.ListaClaseArticulos";
                String connectionString = "Data Source=project0-server.database.windows.net;Initial Catalog=project0-database;Persist Security Info=True;User ID=stevensql;Password=Killua36911-";

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();                                      //Se abre la coneccion con la BD.
                    using (SqlCommand command = new SqlCommand(SPNombre, connection))
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
                                ClaseArticulo claseArticulo = new ClaseArticulo();
                                
                                claseArticulo.Nombre = "" + row[0];

                                listaClaseArticulos.Add(claseArticulo);             //A?adir cada fila al array para su visualizacion.
                            }
                        }
                        else
                        {
                            //En caso de que haya algun error al cargar la tabla de articulos.
                            errorMessage = "Error al cargar la lista de articulos.";
                            return;
                        }
                    }

                    //SEGUNDO SP

                    SPNombre = "dbo.ObtenerArticuloPorClase";

                    using (SqlCommand command = new SqlCommand(SPNombre, connection))
                    {
                        //Variables para obtener el DataSet mandados de la BD.
                        SqlDataAdapter adapter = new SqlDataAdapter();
                        DataTable table = new DataTable();

                        command.CommandType = CommandType.StoredProcedure;  //Indicar que el comando sera un SP.
                        command.Parameters.AddWithValue("@inCodigo", codigoIngresado);

                        //Codigo para que detecte el output del SP.
                        SqlParameter resultCodeParam = new SqlParameter("@outResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(resultCodeParam);
                        command.ExecuteNonQuery();


                        //Porceso de obtener el DataSet.
                        adapter.SelectCommand = command;
                        DataSet dataSet = new DataSet();
                        adapter.Fill(dataSet);

                        int resultCode = (int)command.Parameters["@outResultCode"].Value;
                        Console.WriteLine(resultCode);

                        //Si el output de errores por DataSet es 0 (No hay problemas).
                        if (dataSet.Tables[0].Rows[0][0].ToString().Equals("0"))
                        {

                            foreach (DataRow row in dataSet.Tables[1].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                articulo.Codigo = "" + codigoIngresado;
                                articulo.Clase = "" + row[0];
                                articulo.Nombre = "" + row[1];
                                articulo.Precio = "" + SqlMoney.Parse(row[2].ToString());
                                idArticulo = int.Parse("" + row[3]);
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

        public void OnPost()
        {
            articulo.Codigo = Request.Form["Codigo"];
            articulo.Nombre = Request.Form["Nombre"];
            articulo.Clase = Request.Form["ClaseSeleccionada"];
            articulo.Precio = Request.Form["Precio"];
            idArticulo = int.Parse(Request.Form["idArticulo"]);

            try
            {
                String connectionString = "Data Source=project0-server.database.windows.net;Initial Catalog=project0-database;Persist Security Info=True;User ID=stevensql;Password=Killua36911-";
                
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    
                    connection.Open();

                    String SPNombre = "dbo.ListaClaseArticulos";
                    using (SqlCommand command = new SqlCommand(SPNombre, connection))
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
                                ClaseArticulo claseArticulo = new ClaseArticulo();

                                claseArticulo.Nombre = "" + row[0];

                                listaClaseArticulos.Add(claseArticulo);             //A?adir cada fila al array para su visualizacion.
                            }
                            

                        }
                        else
                        {
                            //En caso de que haya algun error al cargar la tabla de articulos.
                            errorMessage = "Error al cargar la lista de articulos.";
                            return;
                        }
                    }

                    if (articulo.Codigo.Length == 0 || articulo.Nombre.Length == 0 || articulo.Clase.Length == 0 || articulo.Precio.Length == 0)
                    {
                        errorMessage = "Todos los datos son requeridos.";
                        return;
                    }
                    //Comprobar el formato

                    //Comprobar que el nombre solo contenga letras o guines
                    if (!articulo.Nombre.All(c => (Char.IsLetter(c) || c == '-')))
                    {
                        errorMessage = "El nombre solo puede contener letras o guines";
                        return;
                    }
                    //Comprobar que el precio solo contenga numeros o comas
                    if (!articulo.Precio.All(c => (c >= '0' && c <= '9') || c == ','))
                    {
                        errorMessage = "El precio solo puede tener valores numéricos o coma";
                        return;
                    }

                    string spName = "dbo.ModificarArticulo";
                    using (SqlCommand command = new SqlCommand(spName, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                       
                        command.Parameters.AddWithValue("@inID", idArticulo);
                        command.Parameters.AddWithValue("@inClase", articulo.Clase);
                        command.Parameters.AddWithValue("@inCodigo", articulo.Codigo);
                        command.Parameters.AddWithValue("@inNombre", articulo.Nombre);
                        command.Parameters.AddWithValue("@inPrecio", SqlMoney.Parse(articulo.Precio));
                        SqlParameter resultCodeParam = new SqlParameter("@outResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(resultCodeParam);

                        command.ExecuteNonQuery();

                        int resultCode = (int)command.Parameters["@outResultCode"].Value;
                        if (resultCode == 50001) //codigo generado en el SP que dice si ya un nombre del articulo existe o no
                        {
                            errorMessage = "No puede actualizar nombre de articulo con un nombre ya existente";
                            return;
                        }
                        if (resultCode == 50002) //codigo generado en el SP que dice si ya un nombre del articulo existe o no
                        {   
                            errorMessage = "No puede actualizar código de articulo con un código ya existente";
                            return;
                        }
                    }

                    
                }

            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return;
            }
            articulo.Clase = "";
            articulo.Codigo = "";
            articulo.Nombre = "";
            articulo.Precio = "";
            successMessage = "Articulo modificado correctamente.";

            //Response.Redirect("/Exito");

        }
    }
}
