Code.require_file("Util.ex", __DIR__)

defmodule Cookie do
  @longitud_llave 128
  def main() do
    :crypto.strong_rand_bytes(@longitud_llave)
    |> Base.encode64()
    |> Util.mostrar_mensaje()
  end
end

Cookie.main()
