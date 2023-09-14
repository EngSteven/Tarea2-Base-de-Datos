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
        public String codigoIngresado = "34A67E";
        public String errorMessage = "";                                    //Variable para los mensajes de error
        public String successMessage = "";
        public ArticuloInfo articulo = new ArticuloInfo();


        public void OnGet()
        {
            try
            {   
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

                        //Si el output de errores por DataSet es 0 (No hay problemas).
                        if (dataSet.Tables[0].Rows[0][0].ToString().Equals("0"))
                        {

                            foreach (DataRow row in dataSet.Tables[1].Rows) //Recorra cada fila de la tabla con los datos y estraigala en el tipo ClienteInfo.
                            {
                                articulo.Codigo = "" + codigoIngresado;
                                articulo.ClaseArticulo = "" + row[0];
                                articulo.Nombre = "" + row[1];
                                articulo.Precio = "" + SqlMoney.Parse(row[2].ToString());
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



    public class ClaseArticulo                                                //Clase que equivaldra a las filas de la tabla para si manipulacion.
    {
        public String Nombre;
    }

    public class ArticuloInfo                                                //Clase que equivaldra a las filas de la tabla para si manipulacion.
    {
        public String Codigo;
        public String ClaseArticulo;
        public String Nombre;
        public String Precio;
    }

}
