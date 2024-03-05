module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # field :user, Types::UserType, null: false do # GraphQLクエリでのfield名、GraphQL Type、必須かどうか
    #   argument :id, ID, required: true # GraphQLクエリでの引数、GraphQLでの型、必須かどうか
    # end

    # def user(id:) # fieldが指定されたとき、どのようにデータ取得するかをfieldと同名メソッドで実装する
    #   User.find(id)
    # end
    field :user, resolver: Resolvers::UserResolver

    # field :users, [Types::UserType], null: false
    # def users
    #   User.all
    # end
    field :users, resolver: Resolvers::UsersResolver

    field :book, resolver: Resolvers::BookResolver
    field :books, resolver: Resolvers::BooksResolver
  end
end
