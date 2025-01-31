import"./Navbar.astro_astro_type_script_index_0_lang.B7ReFUZd.js";function i(){fetch("https://api.github.com/repos/gopi2401/insta/releases").then(e=>e.json()).then(e=>{h(e)}).catch(e=>console.error("Error fetching data:",e))}function h(e){const p=document.getElementById("data-body");p.innerHTML="",e.forEach(t=>{const o=document.createElement("tr"),a=document.createElement("th");a.setAttribute("class","px-2 md:px-6 py-4 text-white"),a.setAttribute("scope","row");const d=document.createElement("a");d.setAttribute("class","hover:text-blue-800"),d.textContent=t.tag_name,d.href=t.html_url,a.appendChild(d),o.appendChild(a);const r=document.createElement("th");r.setAttribute("class","px-2 md:px-6 py-4 text-white"),r.setAttribute("scope","row"),r.textContent=`${new Date(t.published_at).getDate()}/${new Date(t.published_at).getMonth()+1}/${new Date(t.published_at).getFullYear()}`,o.appendChild(r);for(let l=0;l<t.assets.length;l++){const s=document.createElement("th");s.setAttribute("class","px-2 md:px-6 py-4"),s.setAttribute("scope","row");const n=document.createElement("a");n.href=t.assets[l].browser_download_url,n.innerHTML=`<svg
                                        width="24"
                                        height="24"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        xmlns="http://www.w3.org/2000/svg"
                                    >
                                        <g id="Interface / Download">
                                            <path
                                                id="Vector"
                                                d="M6 21H18M12 3V17M12 17L17 12M12 17L7 12"
                                                stroke="#000000"
                                                stroke-width="2"
                                                stroke-linecap="round"
                                                stroke-linejoin="round"></path>
                                        </g>
                                    </svg>`;const c=document.createElement("p");c.setAttribute("class","hidden md:block"),c.innerText="Download",n.setAttribute("class","p-3 md:py-3 md:px-5 inline-flex items-center md:gap-x-2 text-sm font-medium rounded-lg border border-gray-200 bg-gray-800 text-white shadow-sm hover:bg-gray-700"),n.appendChild(c),s.appendChild(n),o.appendChild(s)}p?.appendChild(o)})}document.addEventListener("DOMContentLoaded",i);
