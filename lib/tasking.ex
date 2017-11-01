defmodule Tasking do
    @moduledoc false

    @max_task_workers 10

    def pblur(matrix) do
        split_matrix = BlurProcess.split_by(matrix, @max_task_workers)
        worker_count = Enum.count(split_matrix)

        split_matrix
        |> Enum.with_index(1)
        |> Enum.map(fn x -> Task.async(fn -> process_bluring(x, worker_count) end) end)
        |> Enum.flat_map(&(Task.await(&1, :infinity)))
    end

    def process_bluring({matrix, index}, count) do
        matrix
        |> BlurProcess.start(Matrix.count(matrix))
        |> BlurProcess.row_processing(index, count)
    end
end
