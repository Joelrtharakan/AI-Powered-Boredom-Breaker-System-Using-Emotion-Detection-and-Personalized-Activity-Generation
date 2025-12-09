
import { motion } from 'framer-motion';
import { Play, Heart, Share2, MoreHorizontal, Disc } from 'lucide-react';
import { useState, useEffect } from 'react';
import axios from 'axios';

export default function Music() {
    const [isPlaying, setIsPlaying] = useState(false);
    const [playlists, setPlaylists] = useState([]);
    const [currentTrack, setCurrentTrack] = useState(null);

    useEffect(() => {
        const fetchMusic = async () => {
            try {
                // Determine mood from last detection or default
                const mood = 'chill';
                const res = await axios.get(`http://localhost:8000/api/v1/music?mood=${mood}`);
                setPlaylists(res.data.playlists || []);
                // Optionally set the first track of the first playlist as currentTrack
                if (res.data.playlists && res.data.playlists.length > 0 && res.data.playlists[0].tracks.length > 0) {
                    setCurrentTrack(res.data.playlists[0].tracks[0]);
                }
            } catch (e) {
                console.error(e);
            }
        };
        fetchMusic();
    }, []);

    const togglePlay = () => setIsPlaying(!isPlaying);

    return (
        <div className="min-h-screen pt-20 pb-24 px-4 max-w-7xl mx-auto">
            <div className="flex flex-col md:flex-row justify-between items-end mb-12 gap-6">
                <div>
                    <h1 className="text-5xl font-black title-gradient mb-4">Sonic Heal</h1>
                    <p className="text-gray-400 max-w-lg">AI-curated soundscapes to harmonize your current emotional state.</p>
                </div>
                <div className="flex gap-2">
                    <button className="px-4 py-2 rounded-full border border-white/10 text-sm hover:bg-white/5 active:bg-white/10 transition-colors">Relax</button>
                    <button className="px-4 py-2 rounded-full border border-white/10 text-sm hover:bg-white/5 active:bg-white/10 transition-colors">Focus</button>
                    <button className="px-4 py-2 rounded-full border border-white/10 text-sm hover:bg-white/5 active:bg-white/10 transition-colors">Energize</button>
                </div>
            </div>

            {/* Hero Player */}
            <div className="glass-card p-0 overflow-hidden mb-16 flex flex-col md:flex-row">
                <div className="w-full md:w-1/3 bg-gradient-to-br from-primary-dark to-black p-8 flex items-center justify-center relative">
                    <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 10, repeat: Infinity, ease: "linear" }}
                        className="w-48 h-48 rounded-full border-4 border-white/10 relative z-10 shadow-[0_0_50px_rgba(109,40,217,0.5)] bg-black"
                    >
                        <div className="absolute inset-0 rounded-full bg-[url('https://source.unsplash.com/random/400x400/?abstract')] bg-cover opacity-60" />
                        <div className="absolute inset-[40%] rounded-full bg-black border border-white/20" />
                    </motion.div>
                </div>
                <div className="flex-1 p-8 md:p-12 flex flex-col justify-center bg-black/40">
                    <div className="flex justify-between items-start mb-6">
                        <div>
                            <h4 className="text-sm uppercase tracking-widest text-primary-light font-bold mb-2">Now Playing</h4>
                            <h2 className="text-3xl font-bold mb-1">Cosmic Drift</h2>
                            <p className="text-gray-400">Stellar Frequencies</p>
                        </div>
                        <button className="p-2 rounded-full hover:bg-white/10"><Heart size={20} /></button>
                    </div>

                    {/* Progress */}
                    <div className="w-full h-1 bg-white/10 rounded-full mb-2 cursor-pointer group">
                        <div className="w-1/3 h-full bg-white rounded-full relative group-hover:bg-primary-light transition-colors">
                            <div className="absolute right-0 top-1/2 -translate-y-1/2 w-3 h-3 bg-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity" />
                        </div>
                    </div>
                    <div className="flex justify-between text-xs text-gray-500 mb-8">
                        <span>1:24</span>
                        <span>3:45</span>
                    </div>

                    <div className="flex items-center gap-6">
                        <button className="text-gray-400 hover:text-white"><Share2 size={20} /></button>
                        <div className="flex-1 flex items-center justify-center gap-6">
                            <button className="text-3xl hover:text-primary-light transition-colors">⏮</button>
                            <button className="w-16 h-16 rounded-full bg-white text-black flex items-center justify-center hover:scale-105 transition-transform shadow-lg shadow-white/20">
                                <Play className="ml-1 fill-black" size={28} />
                            </button>
                            <button className="text-3xl hover:text-primary-light transition-colors">⏭</button>
                        </div>
                        <button className="text-gray-400 hover:text-white"><MoreHorizontal size={20} /></button>
                    </div>
                </div>
            </div>

            {/* Grid */}
            <h3 className="text-2xl font-bold mb-6">Recommended for You</h3>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6">
                {playlists.map((item, i) => (
                    <motion.div
                        key={i}
                        whileHover={{ y: -10 }}
                        className="group cursor-pointer"
                        onClick={() => setCurrentTrack(item.tracks[0])}
                    >
                        <div className={`aspect-square rounded-2xl bg-gradient-to-br from-primary to-neon-purple mb-4 relative overflow-hidden shadow-lg`}>
                            {item.tracks[0]?.album_art && <img src={item.tracks[0].album_art} alt="art" className="w-full h-full object-cover" />}
                            <div className="absolute inset-0 bg-black/20 group-hover:bg-black/40 transition-colors" />
                            <div className="absolute bottom-4 right-4 translate-y-10 group-hover:translate-y-0 transition-transform duration-300 opacity-0 group-hover:opacity-100">
                                <div className="w-10 h-10 rounded-full bg-primary text-white flex items-center justify-center shadow-lg">
                                    <Play size={16} fill="white" />
                                </div>
                            </div>
                            {/* Mood Tag */}
                            <div className="absolute top-2 left-2 px-2 py-1 bg-black/50 backdrop-blur-md rounded-lg text-[10px] font-bold uppercase tracking-wider">
                                {item.name.split(' ')[0]}
                            </div>
                        </div>
                        <h3 className="font-bold truncate">{item.name}</h3>
                        <p className="text-sm text-gray-500 truncate">{item.tracks.length} Tracks</p>
                    </motion.div>
                ))}
            </div>
        </div>
    )
}
