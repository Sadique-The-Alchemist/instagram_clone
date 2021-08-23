defmodule InstagramCloneWeb.UserLive.Profile do
  use InstagramCloneWeb, :live_view
  alias InstagramClone.Accounts
  alias InstagramCloneWeb.UserLive.FollowComponent
  @impl true
  def mount(%{"username" => username}, session, socket) do
    socket = assign_defaults(session, socket)
    user = Accounts.profile(username)

    {:ok,
     socket
     |> assign(user: user)
     |> assign(page_title: "#{user.full_name}@#{user.username}")}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action)}
  end

  def handle_info({FollowComponent, :update_totals, updated_user}, socket) do
    {:noreply, socket |> assign(user: updated_user)}
  end

  defp apply_action(socket, :index) do
    live_action = get_live_action(socket.assigns.user, socket.assigns.current_user)
    assign(socket, live_action: live_action)
  end

  defp apply_action(socket, :followers) do
    followers = Accounts.list_followers(socket.assigns.user)
    assign(socket, followers: followers)
  end

  defp apply_action(socket, :following) do
    following = Accounts.list_followings(socket.assigns.user)
    assign(socket, following: following)
  end

  defp get_live_action(user, current_user) do
    cond do
      user === current_user -> :edit_profile
      current_user -> :follow_component
      true -> :login_btn
    end
  end
end
