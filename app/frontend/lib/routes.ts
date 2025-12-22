type RouteConfig = Record<string, string>;
type RouteHelpers<T extends RouteConfig> = {
  [K in keyof T]: () => T[K];
};

const createRoutes = <T extends RouteConfig>(routes: T): RouteHelpers<T> =>
  Object.fromEntries(
    Object.entries(routes).map(([key, value]) => [key, () => value])
  ) as RouteHelpers<T>;

export const routes = createRoutes({
  userLists: "/user_lists",
  signup: "/signup",
  login: "/login",
  logout: "/logout"
});
