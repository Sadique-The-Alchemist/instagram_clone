defmodule InstagramClone.Acconts.Follows do
  use Ecto.Schema
  import Ecto.Changeset
  alias InstagramClone.Acconts.User

  schema "accounts_follows" do
    belongs_to :follower, User
    belongs_to :followed, User
    timestamps()
  end

  @doc false
  def changeset(follows, attrs) do
    follows
    |> cast(attrs, [])
    |> validate_required([])
  end
end
