defmodule Blur.Supervisor do
    @moduledoc false

    use Supervisor

    alias Blur.Worker

    @registered_name __MODULE__
    @max_workers 10

    def start_link do
        Supervisor.start_link(@registered_name, :no_args, [name: @registered_name])
    end

    def init(:no_args) do
        children = [worker(Worker, [], restart: :transient)]
        supervise(children, strategy: :simple_one_for_one)
    end

    def start_bluring(matrix) do
        split_matrix = BlurProcess.split_by(matrix, @max_workers)
        split_matrix
        |> Enum.count()
        |> start_children()
        |> assign_tasks(split_matrix)
    end

    def fetch_bluring(blur_pids) do
        stich_results(blur_pids, 1, Enum.count(blur_pids))
    end

    def stich_results([], _, _), do: []
    def stich_results([pid | pids], index, size) do
        Worker.fetch(pid, index, size) ++ stich_results(pids, index + 1, size)
    end

    def stop_workers do
        @registered_name
        |> Supervisor.which_children()
        |> Enum.each(fn child ->
            case child do
                {_, pid, _, _} -> Supervisor.terminate_child(@registered_name, pid)
                _val -> :ok
            end
        end)
    end

    defp assign_tasks([], []), do: []
    defp assign_tasks([blur_pid | blur_tail], [matrix | matrix_tail]) do
        Worker.process(blur_pid, matrix)
        [blur_pid | assign_tasks(blur_tail, matrix_tail)]
    end

    defp start_children(worker_count) do
        all_names = for c <- 1..worker_count, do: process_name(c)

        Enum.map(all_names, fn name ->
            {:ok, blurx_pid} = Supervisor.start_child(@registered_name, [[name: name]])
            blurx_pid
        end)
    end

    defp process_name(id) do
        String.to_atom("blur_process_#{id}")
    end

end
