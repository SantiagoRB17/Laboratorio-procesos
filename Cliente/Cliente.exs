Code.require_file("Util.ex", __DIR__)

defmodule NodoCliente do
  @nombre_servicio_local :servicio_respuesta
  @nodo_remoto :nodoservidor@servidor
  @servicio_remoto {:servicio_trabajos_de_grado, @nodo_remoto}

  def main do
    Util.mostrar_mensaje("PROCESO CLIENTE")
    registrar_servicio(@nombre_servicio_local)

    establecer_conexion(@nodo_remoto)
    |> iniciar_consulta()
  end

  defp registrar_servicio(nombre_servicio_local) do
    Process.register(self(), nombre_servicio_local)
  end

  defp establecer_conexion(nodo_remoto) do
    Node.connect(nodo_remoto)
  end

  defp iniciar_consulta(false) do
    Util.mostrar_error("No se pudo conectar con el nodo servidor")
  end

  defp iniciar_consulta(true) do
    Util.mostrar_mensaje("Conectado al nodo servidor")
    solicitar_lista_trabajos()
    menu_principal()
  end

  defp solicitar_lista_trabajos do
    send(@servicio_remoto, {self(), {:obtener_trabajos_de_grado}})

    receive do
      lista when is_list(lista) ->
        Util.mostrar_mensaje("\nLista de trabajos de grado disponibles:")
        Enum.each(Enum.with_index(lista), fn {trabajo, indice} ->
          Util.mostrar_mensaje("#{indice + 1}. #{trabajo.titulo} (#{trabajo.fecha})")
        end)
        Util.mostrar_mensaje("")
        lista

      respuesta ->
        Util.mostrar_mensaje("Respuesta recibida: #{inspect(respuesta)}")
        []
    after
      5000 ->
        Util.mostrar_error("No se recibió respuesta del servidor.")
        []
    end
  end

  defp menu_principal do
    Util.mostrar_mensaje("Menú principal:")
    Util.mostrar_mensaje("1. Listar trabajos de grado")
    Util.mostrar_mensaje("2. Consultar autores de un trabajo (por índice)")
    Util.mostrar_mensaje("3. Consultar autores de un trabajo (por título)")
    Util.mostrar_mensaje("4. Salir")

    opcion = Util.ingresar("Seleccione una opción: ", :texto)

    case opcion do
      "1" ->
        solicitar_lista_trabajos()
        menu_principal()

      "2" ->
        consultar_autores_por_indice()
        menu_principal()

      "3" ->
        consultar_autores_por_titulo()
        menu_principal()

      "4" ->
        Util.mostrar_mensaje("Finalizando cliente...")
        send(@servicio_remoto, {self(), :fin})

      _ ->
        Util.mostrar_error("Opción inválida")
        menu_principal()
    end
  end

  defp consultar_autores_por_indice do
    indice = Util.ingresar("Ingrese el índice del trabajo (empezando en 1): ", :entero) - 1

    send(@servicio_remoto, {self(), {:consultar_autores_trabajo_de_grado_por_indice, indice}})

    recibir_respuesta_autores()
  end

  defp consultar_autores_por_titulo do
    titulo = Util.ingresar("Ingrese el título del trabajo: ", :texto)

    send(@servicio_remoto, {self(), {:consultar_autores_trabajo_de_grado, titulo}})

    recibir_respuesta_autores()
  end

  defp recibir_respuesta_autores do
    receive do
      autores when is_list(autores) ->
        if autores == [] do
          Util.mostrar_mensaje("No se encontraron autores para este trabajo.")
        else
          Util.mostrar_mensaje("\n Lista de autores del trabajo:")
          Enum.each(autores, fn autor ->
            Util.mostrar_mensaje(
              "  - #{autor.nombre} #{autor.apellidos}"
            )
            Util.mostrar_mensaje("    Cédula: #{autor.cedula}")
            Util.mostrar_mensaje("    Programa: #{autor.programa}")
            Util.mostrar_mensaje("    Título: #{autor.titulo}")
            Util.mostrar_mensaje("")
          end)
        end

      respuesta ->
        Util.mostrar_mensaje("Respuesta recibida: #{inspect(respuesta)}")
    after
      5000 ->
        Util.mostrar_error("No se recibió respuesta del servidor.")
    end
  end
end

NodoCliente.main()
