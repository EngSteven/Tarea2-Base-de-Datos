using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Xml.Linq;

namespace WebApplication2.Pages.Clientes
{
    public class CAModificarModel : PageModel
    {

        public ArticuloInfo articuloInfo = new ArticuloInfo();
        public String errorMessage = "";
        public String successMessage = "";

        public void OnPost()
        {
            articuloInfo.Codigo = Request.Form["Codigo"];

            if (articuloInfo.Codigo.Length == 0)
            {
                errorMessage = "Todos los datos son requeridos.";
                return;
            }
            //Comprobar el formato. 

            //Comprobar que el nombre solo contenga letras o guines
            /*if (!clienteInfo.Nombre.All(c => (Char.IsLetter(c) || c == '-')))
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
                string spName = "dbo.ValidarCodigoArticulo";
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    using (SqlCommand command = new SqlCommand(spName, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;

                        command.Parameters.AddWithValue("@inCodigo", articuloInfo.Codigo);
                        SqlParameter resultCodeParam = new SqlParameter("@outResultCode", SqlDbType.Int);
                        resultCodeParam.Direction = ParameterDirection.Output;
                        command.Parameters.Add(resultCodeParam);

                        command.ExecuteNonQuery();

                        int resultCode = (int)command.Parameters["@outResultCode"].Value;

                        if (resultCode == 50001) //codigo generado en el SP que dice si ya un nombre del articulo existe o no
                        {
                            errorMessage = "El codigo del articulo no existe";
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
            //successMessage = "Nuevo articulo añadido correctamente.";
            TempData["CodigoIngresado"] = articuloInfo.Codigo;
            Response.Redirect("/Cliente/Modificar");

        }
    }
}
