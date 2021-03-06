defmodule Transform.Map do
  def transform(source, target, target_key_fun \\ &use_source_key/1) when is_map(target) do
    target = 
      source
      |> Map.keys
      |> reject_meta_keys
      |> copy_values(source, target, target_key_fun)

    {:ok, target}
  end

  defp reject_meta_keys keys do
    Enum.reject keys, &meta_key?(&1)
  end

  defp meta_key?(key) when is_atom(key),   do: meta_key? Atom.to_string(key)
  defp meta_key?(key) when is_binary(key), do: Regex.match? ~r/^__/, key

  defp copy_values(keys, source, target, target_key) do
    Enum.reduce(keys, target, &copy_value(&1, source, &2, target_key))
  end

  defp copy_value(key, source, target, target_key) do
    Map.put(target, target_key.(key), Map.get(source, key))
  end

  defp use_source_key(key), do: key
end
