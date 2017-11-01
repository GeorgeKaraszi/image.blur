defmodule IBlur do
  @moduledoc """
  Documentation for IBlur.
  """

  use Application

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

    def the_start(matrix \\ Matrix.new(3,3)) do
      matrix
      |> blurx
      |> blury
    end

    def start_p(matrix \\ Matrix.new(10,10)) do
      matrix
      |> Blur.Supervisor.start_bluring()
      |> Blur.Supervisor.fetch_bluring()
    end

  def hello do
    :world
  end

  def start(_type, _args) do
    IO.puts "ERE"
    :observer.start
    Blur.Supervisor.start_link()
  end

end
