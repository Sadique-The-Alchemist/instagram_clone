defmodule InstagramCloneWeb.UserLive.Profile do
  use InstagramCloneWeb, :live_view
  alias InstagramClone.Accounts
  alias InstagramCloneWeb.UserLive.FollowComponent
  @impl true
  def mount(%{"username" => username}, session, socket) do
    socket = assign_defaults(session, socket)
    user = Accounts.profile(username)
    {:ok, socket |> assign(user: user)}
  end

  def handle_info({FollowComponent, :update_totals, updated_user}, socket) do
    {:noreply, socket |> assign(user: updated_user)}
  end
end
