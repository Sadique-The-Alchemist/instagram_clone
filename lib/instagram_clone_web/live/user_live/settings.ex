defmodule InstagramCloneWeb.UserLive.Settings do
  use InstagramCloneWeb, :live_view
  alias InstagramClone.Accounts
  alias InstagramClone.Accounts.User
  alias InstagramClone.Uploaders.Avatar
  # File extensions accepted to be uploaded
  @extenstion_whitelist ~w(.jpg .png .jpeg)

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    changeset = Accounts.change_user(socket.assigns.current_user)

    {:ok,
     socket
     |> assign(changeset: changeset)
     |> assign(page_title: "Edit Profile")
     |> allow_upload(:avatar_url,
       accept: @extenstion_whitelist,
       max_file_size: 9_000_000,
       progress: &handle_progress/3,
       auto_upload: true
     )}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.current_user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successuflly")
         |> push_redirect(to: Routes.live_path(socket, InstagramCloneWeb.UserLive.Settings))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_progress(:avatar_url, entry, socket) do
    if entry.done do
      avatar_url = Avatar.get_avatar_url(socket, entry)
      user_params = %{"avatar_url" => avatar_url}

      case Accounts.update_user(socket.assigns.current_user, user_params) do
        {:ok, _user} ->
          Avatar.update(socket, socket.assigns.current_user.avatar_url, entry)
          # Update current user and get back socket to update header nav avatar

          current_user = Accounts.get_user!(socket.assigns.current_user.id)

          {:norply,
           socket
           |> put_flash(:info, "Avatar updated succesfully")
           |> assign(current_user: current_user)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    end
  end
end
