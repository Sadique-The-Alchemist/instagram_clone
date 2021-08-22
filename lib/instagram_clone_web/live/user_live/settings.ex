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
    settings_path = Routes.live_path(socket, __MODULE__)
    pass_settings_path = Routes.live_path(socket, InstagramCloneWeb.UserLive.PassSettings)

    {:ok,
     socket
     |> assign(changeset: changeset)
     |> assign(page_title: "Edit Profile")
     |> assign(settings_path: settings_path, pass_settings_path: pass_settings_path)
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

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
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

  # def handle_event("update_avatar", _params, socket) do
  #   uploaded_file =
  #     consume_uploaded_entries(socket, :avatar_url, fn %{path: path}, _entry ->
  #       dest =
  #         Path.join([:code.priv_dir(:instagram_clone), "static", "uploads", Path.basename(path)])

  #       File.cp!(path, dest)
  #       Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
  #     end)

  #   {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_file))}
  # end

  def handle_progress(:avatar_url, entry, socket) do
    if entry.done? do
      avatar_url = Avatar.get_avatar_url(socket, entry)
      user_params = %{"avatar_url" => avatar_url}

      case Accounts.update_user(socket.assigns.current_user, user_params) do
        {:ok, _user} ->
          Avatar.update(socket, socket.assigns.current_user.avatar_url, entry)
          # Update current user and get back socket to update header nav avatar

          current_user = Accounts.get_user!(socket.assigns.current_user.id)

          {:noreply,
           socket
           |> put_flash(:info, "Avatar updated succesfully")
           |> assign(current_user: current_user)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_params(_params, uri, socket) do
    {:noreply, socket |> assign(current_uri_path: URI.parse(uri).path)}
  end
end
