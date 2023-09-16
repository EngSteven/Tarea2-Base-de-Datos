using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Data;

namespace WebApplication2.Pages.Clientes
{
    public class InsertarModel : PageModel
    {

        public List<ClaseArticulo> listaClaseArticulos = new List<ClaseArticulo>();
        public String errorMessage = "";                                    //Variable para los mensajes de error
        public String successMessage = "";
        public ArticuloInfo articulo = new ArticuloInfo();

        public void OnGet(string claseSeleccionada)
        {
            try
            {
                Console.WriteLine(claseSeleccionada);
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


            if (articulo.Codigo.Length == 0 || articulo.Nombre.Length == 0 || articulo.Clase.Length == 0 || articulo.Precio.Length == 0)
            {
                errorMessage = "Todos los datos son requeridos.";
                return;
            }
            //Guardar el nuevo cliente
            //Comprobar el formato. 

            /*//Comprobar que el nombre solo contenga letras o guines
            if (!articulo.Nombre.All(c => (Char.IsLetter(c) || c == '-')))
            {
                errorMessage = "El nombre solo puede contener letras o guines";
                return;
            }
            //Comprobar que el precio solo contenga numeros o comas
            if (!clienteInfo.Precio.All(c => (c >= '0' && c <= '9') || c == ','))
            {
                errorMessage = "El precio solo puede tener valores numéricos o coma";
                return;
            }*/

            try
            {
                String connectionString = "Data Source=project0-server.database.windows.net;Initial Catalog=project0-database;Persist Security Info=True;User ID=stevensql;Password=Killua36911-";
                string spName = "dbo.InsertarArticulo";
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    using (SqlCommand command = new SqlCommand(spName, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

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
                            errorMessage = "El nombre del articulo ya existe";
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
            successMessage = "Articulo agregado correctamente.";

            //Response.Redirect("/Exito");

        }

    }
}
