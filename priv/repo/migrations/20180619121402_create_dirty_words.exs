defmodule Filter.Repo.Migrations.CreateDirtyWords do
  use Ecto.Migration

  def change do
    create table(:dirty_words) do
      add :content, :string, unique: true, null: false
      add :level, :integer, null: false

      timestamps()
    end

    create(unique_index(:dirty_words, [:content], name: :unique_contents))
  end
end
