defmodule Blur.Worker do
    @moduledoc false

    use GenServer

    def start_link(opts) do
        GenServer.start_link(__MODULE__, [], opts)
    end

    def init(state) do
        {:ok, state}
    end

    def process(pid, matrix) do
        GenServer.cast(pid, {:process, matrix, Matrix.count(matrix)})
    end

    def fetch(pid, index, count) do
        GenServer.call(pid, {:fetch, index, count}, :infinity)
    end

    # Callbacks

    def handle_call({:fetch, index, count}, _from, state) do
        result   = BlurProcess.row_processing(state, index, count)
        {:stop, :normal, result, result}
    end

    def handle_cast({:process, matrix, matrix_size}, _state) do
        {:noreply, BlurProcess.start(matrix, matrix_size)}
    end
end
