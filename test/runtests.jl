using SwJ1644
using CSV 

#df = ReadData("../lc.csv")
df = CSV.read("../lc.csv")
#@show data 

#plotlc(data)
using DataFrames
#using Test

df2 = sort!(df)
#@show plot(df2[1],df2[4])
#A1 = convert(Array,df2)
t = convert(Array{Float64},df2[1])
y = convert(Array{Float64},df2[4])
#Peaks = peaks(t,y) # An easy way to find the peaks
Peaks,Dips = peaks2(t,y) # A more proper way.

N = Int64(length(Peaks)/ndims(Peaks))
tPeaks1 = Peaks[:,1]
tPeaks2 = ones(N-1) #initialize an array
DeltatPeak = ones(N-1) #initialize an array
for i=1:N-1
    tPeaks2[i] = (tPeaks1[i+1]+tPeaks1[i])/2
    DeltatPeak[i] = tPeaks1[i+1]-tPeaks1[i]
end
println("The observed number of peaks are: ", N-1)

### To get the Period changing theoretically

function eptFun(ep0::Float64,t0::Float64,t::Float64,nTidal::Float64)
    ep1 = ep0*(t/t0)^nTidal
end

function ept(t)
    ep2 = eptFun(ep0,t0,t,nTidal)
end

function main()
    # parameters 
    DL = 3.7e27 # Luminosity distance in unit of cm
    c = 2.9979e10
    eta = 1.e-1 # The efficiency converting mass to X-rays
    mStar = 2e33 # Mass of the star 
    mm = mStar
    ep0 = 1e-3 # ep0: a small value, short for 'epsilon'
    t0 = 1.0 # Right now, the ti is just the number i
    nTidal = -0.2
    MBH = 7e6 # Mass of the central BH, in unit of M_sun
    Rp = 1e14 # Rp: the distance of pericenter to the BH, in unit of cm
    Rp = Rp/1.49597871E13 # convert to AU
    N = 4*Int64(floor(1/ep0)) # the integer part of a float
    dm = ones(N) # Initialize the mass 
    e = zeros(N)
    e[1] = 0.6
    G = 6.67242E-8
    P = zeros(N)
    P[1] = 2*pi/sqrt(G*MBH) * (Rp/(1-e[1]))^1.5
    N2 = 0
    for i in 2:N
        ep = ept(Float64(i))
        tmp1 = sqrt(1+e[i-1])-ep
        e[i] = (tmp1/(1-ep))^2-1.0
        dm[i] = ep * mm
        mm = mm - dm[i] # why global? weird
        if e[i] >= 1.0
            println("This is the last orbit! eccentricity:", e[i], " mass:", mm)
            break
        end
        P[i] = 2*pi/sqrt(G*MBH) * (Rp/(1-e[i]))^1.5
        #println(i, " tmp1: ", tmp1, " e[i]: ", e[i], " P[i]:", P[i])
        N2 = N2 + 1
    end
    e2 = e[1:N2-1] #truncate the tails, which was set to be larger
    P2 = P[1:N2-1]
    tp3 = P2[1]
    tp4 = ones(N2-1)
    tp4[1] = tp3
    for i in 2:N2-1
        tp3 = tp3 + P2[i]
        tp4[i] = tp3
    end
    dm2 = dm[1:N2-1]
    dm2[1] = dm2[2] # tmp use 
    Fx = 1e6 * eta .* dm2 * c^2 / (4*pi*DL^2) ./ P2 #(time)
    println("The predicted number of orbits are: ", N2-1)
end

main()

#= using Plots
#using Gadfly
#plot(tPeaks2,DeltatPeak)
plot(log10.(tPeaks2),log10.(DeltatPeak))
savefig("fig.png")
=#

# To plot the period-t diagram
using RCall
@rlibrary ggplot2
dat = DataFrame(tP=tPeaks2, DP=DeltatPeak)
dat2 = DataFrame(tp2=tp4, DP2=P2)
ggplot(data=dat, aes(x=log10.(dat[:tP]), y=log10.(dat[:DP]))) +
    geom_point(size=2) +
    geom_line(data=dat2, aes(x=log10.(dat2.tp2),y=log10.(dat2.DP2))) +
    geom_point(data=dat2, aes(x=log10.(dat2.tp2),y=log10.(dat2.DP2)), size=1, color="red") +
    xlab("log10(time) (s)") + ylab("log10(Period) (s)")
#print(p)
ggsave(file="Period-t.eps")

# To plot the light curves, together with the peaks, dips and predictions.
tt = DataFrame(t=t, y=y)
dfPeaks = DataFrame(t=Peaks[:,1], p=Peaks[:,2])
dfDips = DataFrame(t=Dips[:,1], d=Dips[:,2])
dfPredicts = DataFrame(tp=tp4)
dfFx = DataFrame(t=tp4, Fx=Fx)
p = ggplot(data=tt, aes(x=tt[:t],y=tt[:y]))+
    geom_point(size=0.1, color="grey")+
    #geom_vline(xintercept=dfPredicts[:tp], size=0.1, color="grey")+
    geom_point(data=dfPeaks, aes(x=dfPeaks[:t],y=dfPeaks[:p]), size=0.5, color="red")+
    #geom_point(data=dfDips, aes(x=dfDips[:t],y=dfDips[:d]), size=0.5, color="blue")+
    geom_point(data=dfFx, aes(x=dfFx[:t],y=dfFx[:Fx]), size=0.2, color="orange")+
    scale_x_log10() + scale_y_log10()+
    xlab("log10(time) (s)") + ylab("log10(Flux) (erg/cm^2/s)")
#p = p + theme(legend.title=element_blank())
#print(p)
ggsave(file="light-curves.pdf")

# Just plot part of the light curves to have a better look
#p = p + xlim(1.5e6,1.6e6)
p = p + xlim(1.e3,5e3)
ggsave(file="light-curves-zoom-in.pdf")
