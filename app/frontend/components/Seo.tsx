import { Head } from "@inertiajs/react";

export type SeoMeta = {
  title: string;
  description: string;
  og_title: string;
  og_description: string;
  og_image: string;
};

type Props = {
  meta: SeoMeta;
};

export function Seo({ meta }: Props) {
  return (
    <Head title={meta.title}>
      <meta name="description" content={meta.description} />
      <meta property="og:title" content={meta.og_title} />
      <meta property="og:description" content={meta.og_description} />
      <meta property="og:image" content={meta.og_image} />
      <meta property="twitter:card" content="summary_large_image" />
    </Head>
  );
}
