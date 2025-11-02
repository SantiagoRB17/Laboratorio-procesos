Code.require_file("Autor.ex", __DIR__)
Code.require_file("TrabajoDeGrado.ex", __DIR__)
Code.require_file("Util.ex", __DIR__)

defmodule NodoServidor do
  @nombre_servicio_local :servicio_trabajos_de_grado
  @archivo_trabajos "../Persistencia/TrabajosDeGrado.csv"
  @archivo_autores "../Persistencia/Autores.csv"

  def main do
    Util.mostrar_mensaje("PROCESO SERVIDOR")
    datos = cargar_datos()
    Util.mostrar_mensaje("Servidor iniciado y esperando solicitudes...")
    registrar_servicio(@nombre_servicio_local)
    procesar_mensajes(datos)
  end

  defp registrar_servicio(nombre_servicio_local) do
    Process.register(self(), nombre_servicio_local)
  end

  defp cargar_datos() do
    trabajos = TrabajoDeGrado.leer_csv(@archivo_trabajos)
    autores = Autor.leer_csv(@archivo_autores)

    Util.mostrar_mensaje("Datos cargados: #{length(trabajos)} trabajos de grado, #{length(autores)} autores")
    {trabajos, autores}
  end

  defp procesar_mensajes({trabajos, autores} = datos) do
    receive do
      {productor, :fin} ->
        send(productor, :fin)

      {productor, {:obtener_trabajos_de_grado}} ->
        send(productor, trabajos)
        procesar_mensajes(datos)

      {productor, {:consultar_autores_trabajo_de_grado, titulo}} ->
        respuesta = consultar_autores_trabajo_de_grado(trabajos, autores, titulo)
        send(productor, respuesta)
        procesar_mensajes(datos)

      {productor, {:consultar_autores_trabajo_de_grado_por_indice, indice}} ->
        respuesta = consultar_autores_trabajo_de_grado_por_indice(trabajos, autores, indice)
        send(productor, respuesta)
        procesar_mensajes(datos)
    end
  end

  defp consultar_autores_trabajo_de_grado(trabajos, autores, titulo) do
    case Enum.find(trabajos, fn t -> t.titulo == titulo end) do
      nil ->
        []

      trabajo ->
        Enum.filter(autores, fn a -> a.cedula in trabajo.autores end)
    end
  end

  defp consultar_autores_trabajo_de_grado_por_indice(trabajos, autores, indice) when is_integer(indice) do
    case Enum.at(trabajos, indice) do
      nil ->
        []

      trabajo ->
        Enum.filter(autores, fn a -> a.cedula in trabajo.autores end)
    end
  end
end

NodoServidor.main()
