export type AuthUser = {
  id: number;
  name: string;
};

export type FlashMessages = {
  notice?: string;
  alert?: string;
};

export type SharedErrors = Record<string, string>;

export type SharedPageProps = {
  auth: {
    user: AuthUser | null;
  };
  flash?: FlashMessages;
  errors?: SharedErrors;
};

export type PageProps<T extends Record<string, unknown> = Record<string, unknown>> = SharedPageProps & T;
