defmodule BlurProcess do
    @moduledoc false

    def row_processing(matrix, index, count) do
        row_size = Enum.count(matrix)
        case index do
            1 ->                          Enum.slice(matrix, 0..row_size - 2)
            _last when index == count ->  Enum.slice(matrix, 1..row_size)
            _middle ->                    Enum.slice(matrix, 1..row_size - 2)
        end
    end

    def start(matrix, {row_size, _} = matrix_size) do
        [output, x_buffer] = process_blur(matrix, matrix_size)
        final_row          = add_col(x_buffer, row_size, matrix_size)
        List.replace_at(output, row_size - 1, final_row)
    end

    def process_blur(matrix, {row_size, _} = matrix_size) do
        buffer = [[], []]
        Enum.reduce(0..row_size - 1, buffer, fn (r, [output, x_buffer]) ->
            results  = add_row(matrix, r, matrix_size)
            x_buffer = List.insert_at(x_buffer, -1, results)
            [process_x_buffer(x_buffer, r, output, matrix_size), x_buffer]
          end)
    end

    def process_x_buffer(buffer, row, output, matrix_size) do
        if Enum.count(buffer) > 1 do
          Enum.reduce(row-1..row, output, fn(r, matrix) ->
            result = add_col(buffer, r, matrix_size)
            List.insert_at(matrix, r - 1, result)
          end)
        else
          output
        end
    end

    def add_col(matrix, row, {_, col_size} = matrix_size) do
        for col <- 0..col_size, col < col_size do
            before  = Matrix.get(matrix, row - 1, col, matrix_size)
            current = Matrix.get(matrix, row, col,     matrix_size)
            next    = Matrix.get(matrix, row + 1, col, matrix_size)
            round((before + current + next) / 3)
        end
    end

    def add_row(matrix, row, {_, col_size} = matrix_size) do
        for col <- 0..col_size, col < col_size do
            before  = Matrix.get(matrix, row, col - 1, matrix_size)
            current = Matrix.get(matrix, row, col,     matrix_size)
            next    = Matrix.get(matrix, row, col + 1, matrix_size)
            round((before + current + next) / 3)
        end
    end

    def split_by(matrix, workers) do
        row_count = Enum.count(matrix)
        if row_count < workers + 1 do
            [matrix]
        else
            split_amount = round(row_count / workers)
            Enum.chunk_every(matrix, split_amount + 1, split_amount - 1)
        end
    end
end
