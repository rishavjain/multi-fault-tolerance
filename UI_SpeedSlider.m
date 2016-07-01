function UI_SpeedSlider(source,callbackdata)

global A Speed dT;

newSpeed = get(source, 'Value');
DeltaSpeed = newSpeed - Speed;

for i=1:length(A)
    A(i).Speed = A(i).Speed + DeltaSpeed;
end

dT = newSpeed * dT / Speed;
Speed = newSpeed;


end