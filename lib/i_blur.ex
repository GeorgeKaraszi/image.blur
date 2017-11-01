defmodule IBlur do
  @moduledoc """
  Documentation for IBlur.
  """

  use Application

  alias Benchee.Formatters.{HTML, Console}

  @doc """
  Hello world.

  ## Examples

      iex> IBlur.hello
      :world

  """

  def blurx(matrix), do: blurx(matrix, Matrix.count(matrix))
  def blurx(matrix, {row_size, col_size} = matrix_size) do
    for r <- 0..row_size, r < row_size do
      for c <- 0..col_size, c < col_size do
          before  = Matrix.get(matrix, r, c - 1, matrix_size)
          current = Matrix.get(matrix, r, c,     matrix_size)
          next    = Matrix.get(matrix, r, c + 1, matrix_size)
          round((before + current + next) / 3)
      end
    end
  end


  def blury(matrix), do: blury(matrix, Matrix.count(matrix))
  def blury(matrix, {row_size, col_size} = matrix_size) do
    for r <- 0..row_size, r < row_size do
      for c <- 0..col_size, c < col_size do
          before  = Matrix.get(matrix, r - 1, c, matrix_size)
          current = Matrix.get(matrix, r, c,     matrix_size)
          next    = Matrix.get(matrix, r + 1, c, matrix_size)
          round((before + current + next) / 3)
      end
    end
  end

    def kiss_start(matrix \\ Matrix.new(50, 50)) do
      matrix
      |> blurx
      |> blury
    end

    def concurrent_start(matrix \\ Matrix.new(50, 50)) do
      matrix
      |> Blur.Supervisor.start_bluring()
      |> Blur.Supervisor.fetch_bluring()
    end

    def task_start(matrix \\ Matrix.new(50, 50)) do
      Tasking.pblur(matrix)
    end

    def benchmarking do
      matrix_50  = Matrix.new(50, 50)
      matrix_200 = Matrix.new(200, 200)
      matrix_500 = Matrix.new(500, 500)

      Benchee.run(%{
        "KISS 50 x 50"      => fn -> kiss_start(matrix_50) end,
        "task 50 x 50"      => fn -> task_start(matrix_50) end,
        "GenServer 50 x 50" => fn -> concurrent_start(matrix_50) end,

        "KISS 200 x 200"      => fn -> kiss_start(matrix_200) end,
        "task 200 x 200"      => fn -> task_start(matrix_200) end,
        "GenServer 200 x 200" => fn -> concurrent_start(matrix_200) end,

        "KISS 500 x 500"      => fn -> kiss_start(matrix_500) end,
        "task 500 x 500"      => fn -> task_start(matrix_500) end,
        "GenServer 500 x 500" => fn -> concurrent_start(matrix_500) end,
      }, time: 60, print: [fast_warning: false],
      formatters: [&HTML.output/1, &Console.output/1],
      formatter_options: [html: [file: "samples_output/my.html"]])
    end

  def hello do
    :world
  end

  def start(_type, _args) do
    # :observer.start
    Blur.Supervisor.start_link()
  end

end
