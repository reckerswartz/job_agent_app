module DataTableHelper
  def sort_indicator(column)
    return "" unless params[:sort] == column.to_s
    params[:dir] == "asc" ? " ▲" : " ▼"
  end

  def sort_url(column, base_path)
    new_dir = (params[:sort] == column.to_s && params[:dir] != "asc") ? "asc" : "desc"
    "#{base_path}?#{request.query_parameters.merge('sort' => column, 'dir' => new_dir).to_query}"
  end

  def per_page_limit
    limit = params.fetch(:per, 20).to_i
    [[limit, 5].max, 100].min
  end
end
