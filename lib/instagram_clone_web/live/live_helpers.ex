defmodule InstagramCloneWeb.LiveHelpers do
  import Phoenix.LiveView
  alias InstagramClone.{Accounts, Accounts.User}
  alias InstagramCloneWeb.UserAuth
  import Phoenix.LiveView.Helpers

  def assign_defaults(session, socket) do
    if connected?(socket), do: InstagramCloneWeb.Endpoint.subscribe(UserAuth.pubsub_topic())

    assign_new(socket, :current_user, fn ->
      find_current_user(session)
    end)
  end

  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    width = Keyword.fetch!(opts, :width)
    modal_opts = [id: :modal, return_to: path, width: width, component: component, opts: opts]
    live_component(socket, InstagramCloneWeb.ModalComponent, modal_opts)
  end

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end
end
