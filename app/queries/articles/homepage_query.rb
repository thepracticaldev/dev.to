module Articles
  class HomepageQuery
    DEFAULT_PER_PAGE = 60
    MAX_PER_PAGE = 100

    # TODO: [@rhymes] change frontend to start from page 1
    def initialize(sort_by: :hotness_score, sort_direction: :desc, page: 0, per_page: DEFAULT_PER_PAGE)
      @relation = Article.published

      @sort_by = sort_by
      @sort_direction = sort_direction

      @page = page.to_i + 1
      @per_page = [(per_page || DEFAULT_PER_PAGE).to_i, MAX_PER_PAGE].min
    end

    def self.call(...)
      new(...).call
    end

    def call
      sort.merge(paginate)
    end

    private

    attr_accessor :relation
    attr_reader :sort_by, :sort_direction, :page, :per_page

    def sort
      relation.order(sort_by => sort_direction)
    end

    def paginate
      relation.page(page).per(per_page)
    end
  end
end
