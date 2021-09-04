defmodule InstagramCloneWeb.UserLive.Profile do
  use InstagramCloneWeb, :live_view
  alias InstagramClone.{Accounts, Posts}
  alias InstagramCloneWeb.UserLive.FollowComponent
  @impl true
  def mount(%{"username" => username}, session, socket) do
    socket = assign_defaults(session, socket)
    user = Accounts.profile(username)

    {:ok,
     socket
     |> assign(page: 1, per_page: 15)
     |> assign(user: user)
     |> assign(page_title: "#{user.full_name}@#{user.username}")
     |> assign_posts(), temporary_assigns: [posts: []]}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action)}
  end

  def handle_info({FollowComponent, :update_totals, updated_user}, socket) do
    {:noreply, socket |> assign(user: updated_user)}
  end

  @impl true

  def handle_event("load-more-profile-posts", _, socket) do
    {:noreply, load_posts(socket)}
  end

  defp load_posts(socket) do
    total_posts = socket.assigns.user.posts_count
    page = socket.assigns.page
    per_page = socket.assigns.per_page
    total_pages = ceil(total_posts / per_page)

    if page == total_pages do
      socket
    end

    socket
    |> update(:page, &(&1 + 1))
    |> assign_posts()
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

  defp assign_posts(socket) do
    socket
    |> assign(
      posts:
        Posts.list_profile_posts(
          page: socket.assigns.page,
          per_page: socket.assigns.per_page,
          user_id: socket.assigns.user.id
        )
    )
  end
end
