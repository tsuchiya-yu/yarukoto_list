import { usePage } from "@inertiajs/react";

import type { PageProps } from "@/types/page";

export function FlashMessages() {
  const { flash } = usePage<PageProps>().props;
  if (!flash) {
    return null;
  }

  const messages = [flash.notice && { type: "notice", text: flash.notice }, flash.alert && { type: "alert", text: flash.alert }].filter(
    Boolean
  ) as { type: "notice" | "alert"; text: string }[];

  if (messages.length === 0) {
    return null;
  }

  return (
    <div className="flash-messages">
      {messages.map((message) => (
        <p key={message.type} className={`flash flash--${message.type}`}>
          {message.text}
        </p>
      ))}
    </div>
  );
}
