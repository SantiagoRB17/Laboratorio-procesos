defmodule TrabajoDeGrado do
  defstruct fecha: "", titulo: "", descripcion: "", autores: []

  def crear(titulo, fecha, descripcion, autores) do
    %TrabajoDeGrado{
      titulo: titulo,
      fecha: fecha,
      descripcion: descripcion,
      autores: autores
    }
  end

  def leer_csv(nombre) do
    nombre
    |> File.stream!()
    |> Stream.drop(1) # ignora los encabezados
    |> Enum.filter(&(&1 |> String.trim() != "")) # filtra líneas vacías
    |> Enum.map(&convertir_cadena_trabajo/1)
  end

  defp convertir_cadena_trabajo(cadena) do
    [titulo, fecha, descripcion, autores_str] =
      cadena
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.trim/1)

    autores =
      autores_str
      |> String.split(";")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(&1 != ""))

    TrabajoDeGrado.crear(titulo, fecha, descripcion, autores)
  end
end
