using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Net;
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

        public List<UsuarioInfo> listaArticulos = new List<UsuarioInfo>();
        public UsuarioInfo usuarioInfo = new UsuarioInfo();
        public String successMessage = "";

        public void OnGet()
        {
            Response.Redirect("/Pricipal");
        }
        public void OnPost() {
            //Response.Redirect("/Pricipal");
            //return;
            IPHostEntry host;
            String localIP = "";
            host = Dns.GetHostEntry(Dns.GetHostName());
            localIP = host.AddressList[0].ToString();
            usuarioInfo.Usuario = Request.Form["Usuario"];
            usuarioInfo.Clave = Request.Form["Clave"];


            if (usuarioInfo.Usuario.Equals("") || usuarioInfo.Clave.Equals("")) {
                errorMessage = "Ambos campos deben ser rellenados.";
                return;
            }
            try
            {
                Console.WriteLine("Exception: No Funciono"+ usuarioInfo.Clave.ToString()+ usuarioInfo.Usuario.ToString());
                String connectionString = "Data Source=project0-server.database.windows.net;Initial Catalog=project0-database;Persist Security Info=True;User ID=stevensql;Password=Killua36911-";

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();                                      //Se abre la coneccion con la BD.
                    using (SqlCommand command = new SqlCommand("dbo.BuscarUsuario", connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@inUsuario", usuarioInfo.Usuario);
                        command.Parameters.AddWithValue("@inClave", usuarioInfo.Clave);
                        command.Parameters.AddWithValue("@inIP", localIP);

                        SqlParameter resultCodeParam = new SqlParameter("@outResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(resultCodeParam);

                        command.ExecuteNonQuery();

                        int resultCode = (int)command.Parameters["@outResultCode"].Value;

                        if (resultCode == 50001) //codigo generado en el SP que dice si ya un nombre del articulo existe o no
                        {
                            errorMessage = "Combinacion Usuario/Contraseña no encontrado.";
                            return;
                        }
                        else {
                            Response.Redirect("/Pricipal");
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
    public class UsuarioInfo                                                //Clase que equivaldra a las filas de la tabla para si manipulacion.
    {
        public String Usuario;
        public String Clave;
    }
}