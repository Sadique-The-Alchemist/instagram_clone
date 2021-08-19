defmodule InstagramCloneWeb.UserLive.Profile do
  use InstagramCloneWeb, :live_view
  alias InstagramClone.Accounts
  @impl true
  def mount(%{"username" => username}, session, socket) do
    socket = assign_defaults(session, socket)
    current_user = socket.assigns.current_user
    user = Accounts.profile(username)

    get_assigns(socket, current_user, user)
  end

  defp get_follow_btn_name? do
    "Follow"
  end

  defp get_follow_btn_styles? do
    "py-1 mx-5 px-5 border-none shadow rounded text-gray-50 hover:bg-light-blue-600 bg-light-blue-500 focus:outline-none"
  end

  defp get_assigns(socket, current_user, user) do
    if current_user && current_user !== user do
      follow_btn_name? = get_follow_btn_name?()
      follow_btn_styles? = get_follow_btn_styles?()

      {:ok,
       socket
       |> assign(follow_btn_name?: follow_btn_name?)
       |> assign(follow_btn_styles?: follow_btn_styles?)}
    else
      {:ok, socket}
    end
  end
end
