defmodule Autor do
  defstruct nombre: "", apellidos: "", cedula: "", programa: "", titulo: ""

  def crear(cedula, nombre, apellidos, programa, titulo) do
    %Autor{
      cedula: cedula,
      nombre: nombre,
      apellidos: apellidos,
      programa: programa,
      titulo: titulo
    }
  end

  def leer_csv(nombre) do
    nombre
    |> File.stream!()
    |> Stream.drop(1) # ignora los encabezados
    |> Enum.map(&convertir_cadena_autor/1)
  end

  defp convertir_cadena_autor(cadena) do
    [cedula, nombre, apellidos, programa, titulo] =
      cadena
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.trim/1)

    Autor.crear(cedula, nombre, apellidos, programa, titulo)
  end
end
