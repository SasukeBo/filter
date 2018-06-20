defmodule Filter.DirtyWords do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dirty_words" do
    field(:content, :string)
    field(:level, :integer)

    timestamps()
  end

  def changeset(word, params \\ %{}) do
    word
    |> cast(params, [:content, :level])
    |> validate_required([:content, :level])
  end
end
