type RouteConfig = Record<string, string>;
type RouteHelpers<T extends RouteConfig> = {
  [K in keyof T]: () => T[K];
};

const createRoutes = <T extends RouteConfig>(routes: T): RouteHelpers<T> => {
  const helpers = {} as RouteHelpers<T>;
  (Object.keys(routes) as (keyof T)[]).forEach((key) => {
    helpers[key] = () => routes[key];
  });
  return helpers;
};

export const routes = createRoutes({
  userLists: "/user_lists",
  signup: "/signup",
  login: "/login",
  logout: "/logout"
});
