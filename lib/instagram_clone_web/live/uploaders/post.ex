defmodule InstagramClone.Uploaders.Post do
  alias InstagramClone.Posts.Post
  alias InstagramCloneWeb.Router.Helpers, as: Routes

  @upload_directory_name "uploads"
  @upload_directory_path "/priv/static/uploaders"

  def ext(entry) do
    [ext | _] = MIME.extensions(entry)
    ext
  end

  def put_image_url(socket, %Post{} = post) do
    {completed, []} = Phoenix.LiveView.uploaded_entries(socket, :photo_url)

    urls =
      for entry <- completed do
        Routes.static_path(socket, "/#{@upload_directory_name}/#{entry.uuid}#{ext(entry)}")
      end

    %Post{post | photo_url: List.to_string(urls)}
  end

  def save(socket) do
    if !File.exists?(@upload_directory_path), do: File.mkdir!(@upload_directory_path)

    Phoenix.LiveView.consume_uploaded_entries(socket, :photo_url, fn meta, entry ->
      dest = Path.join(@upload_directory_path, "#{entry.uuid}#{ext(entry)}")
      File.cp!(meta.path, dest)
    end)

    :ok
  end
end
