type RouteConfig = Record<string, string | ((...args: unknown[]) => string)>;
type RouteHelpers<T extends RouteConfig> = {
  [K in keyof T]: T[K] extends (...args: infer A) => string ? (...args: A) => string : () => T[K];
};

const createRoutes = <T extends RouteConfig>(routes: T): RouteHelpers<T> =>
  Object.fromEntries(
    Object.entries(routes).map(([key, value]) => [
      key,
      typeof value === "function" ? value : () => value
    ])
  ) as RouteHelpers<T>;

export const routes = createRoutes({
  userLists: "/user_lists",
  userList: (id: number | string) => `/user_lists/${id}`,
  userListItems: (listId: number | string) => `/user_lists/${listId}/items`,
  userListItem: (listId: number | string, itemId: number | string) =>
    `/user_lists/${listId}/items/${itemId}`,
  userListItemsReorder: (listId: number | string) =>
    `/user_lists/${listId}/items/reorder`,
  signup: "/signup",
  login: "/login",
  logout: "/logout"
});
