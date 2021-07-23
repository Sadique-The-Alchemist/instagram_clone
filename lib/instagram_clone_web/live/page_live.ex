defmodule InstagramCloneWeb.PageLive do
  use InstagramCloneWeb, :live_view
  alias InstagramClone.Accounts
  alias InstagramClone.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    {:ok, socket |> assign(changeset: changeset)}
  end
end
