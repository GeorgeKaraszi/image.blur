defmodule Matrix do
    @moduledoc false

    def new({row, col}, random), do: new(row, col, random)
    def new(row, col, random \\ true) do
        case random do
            false    -> for _n <- 1..row, do: generate_zero_filled(col)
            _default -> for _n <- 1..row, do: generate_random_filled(col)
        end
    end

    def get(matrix, row, col) do
        matrix_size = count(matrix)
        get(matrix, row, col, matrix_size)
    end

    def get(_matrix, row, col, _matrix_size) when row < 0 or col < 0, do: 0
    def get(_matrix, row, col, {row_size, col_size})
            when row > row_size or col > col_size, do: 0

    def get(matrix, row, col, _size) do
        case get_value(matrix, row) do
            :error       -> 0
            {:ok, value} -> value |> get_value(col) |> fallback_zero!()
            value        -> value |> get_value(col) |> fallback_zero!()
        end
    end

    def replace_row(matrix, row, col_set) do
        List.replace_at(matrix, row, col_set)
    end

    def get_row(matrix, index), do: get_value(matrix, index)

    def count(matrix) do
        row_count = Enum.count(matrix)
        col_count = matrix |> List.first() |> Enum.count

        {row_count, col_count}
    end

    def generate_zero_filled(col) do
        col |> generate |> Enum.map(fn _c -> 0 end)
    end

    def generate_random_filled(col) do
        col |> generate |> Enum.map(fn _c -> :rand.uniform(50) end)
    end

    defp generate(row), do: Enum.to_list(1..row)

    defp get_value(matrix, index), do: Enum.fetch(matrix, index)

    defp fallback_zero!(:error), do: 0
    defp fallback_zero!({:ok, value}),  do: value
end
