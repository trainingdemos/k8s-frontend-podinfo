"use client";

import { useState, useEffect } from "react";

interface ContainerData {
  image: {
    registry: string;
    namespace: string;
    repository: string;
    tags: string[];
  };
}

interface ServerData {
  hostname: string;
  ip: string;
}

export default function Home() {
  const [containerData, setContainerData] = useState<ContainerData | null>(
    null
  );
  const [serverData, setServerData] = useState<ServerData | null>(null);

  useEffect(() => {
    const fetchContainerData = async () => {
      try {
        const response = await fetch("/data/container.json");
        const data: ContainerData = await response.json();
        setContainerData(data);
      } catch (err) {
        console.error("Error fetching data:", err);
      }
    };
    fetchContainerData();
  }, []);

  useEffect(() => {
    const fetchServerData = async () => {
      try {
        const response = await fetch("/data/server.json");
        const data: ServerData = await response.json();
        setServerData(data);
      } catch (err) {
        console.error("Error fetching data:", err);
      }
    };
    fetchServerData();
  }, []);

  return (
    <div className="grid grid-rows-[20px_1fr_20px] min-h-screen p-12">
      <main className="grid row-start-2 items-center justify-items-center">
        <div className="grid bg-white bg-opacity-80 border-8 border-slate-200 p-12 pb-14 mb-14 text-center">
          <h1 className="font-semibold text-3xl pb-2">Pod Info</h1>
          <p className="font-light leading-8 text-2xl">Name: <span className="font-normal">{serverData?.hostname}</span></p>
          <p className="font-light leading-8 text-2xl">IP: <span className="font-normal">{serverData?.ip}</span></p>
        </div>
      </main>
      <footer className="grid row-start-3">
        <p className="text-slate-200 text-xs text-right text-nowrap pr-9">
          {containerData ? (
            <>
              {containerData.image.registry
                ? `${containerData.image.registry}/`
                : ""}
              {containerData.image.namespace
                ? `${containerData.image.namespace}/`
                : ""}
              {containerData.image.repository}
              {containerData.image.tags.length > 0
                ? `:${
                    containerData.image.tags[
                      containerData.image.tags.length - 1
                    ]
                  }`
                : ""}
            </>
          ) : (
            "Could not fetch data/container.json"
          )}
        </p>
      </footer>
    </div>
  );
}
