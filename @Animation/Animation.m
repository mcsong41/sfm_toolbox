function anim=Animation(varargin)
% Animation class (with 3D data, projection, camera info ...)
%
% An Animation object has the following properties
%   W        - [ 2 x nPoint x nFrame ] matrix containing the projected
%              animation
%   K        - calibration matrix parameters. Can be [ 3 x nFrame ] or
%              [ 5 x nFrame ] or empty. If all the parameters are the same,
%              use [ 3 x 1 ] and [ 5 x 1 ]. The matrix lists the
%              calibration parameters in the following order
%              Affine
%               K1  K2  0
%               0   K3  0
%               0   0   1
%              Projective
%               K1  K2  K4
%               0   K3  K5
%               0   0   1
%   KFull    - the full version of the above [ 3 x 3 nFrame ] or [ 3 x 3 ]
%   S        - [ 3 x nPoint x nFrame ] matrix containing the 3D
%              animation
%              or [ 2 x nPoint x nFrame ] if working with homographies
%   P        - [ 3 x 4 x nFrame ] projection matrices
%              (can be [ 3 x 3 x nFrame ] in the case of homographies)
%              If it is empty, only K,R,t are used
%   R        - [ 3 x 3 x nFrame ] camera rotation. Can be empty (only P is
%              used)
%   t        - [ 3 x nFrame ] camera translation. Can be empty (only P is
%              used)
%   mask     - [ nPoint x nFrame ] mask of appearance: 1 the point appears
%              in the frame, 0 it does not
%   conn     - cell of arrays indicating connectivities: each point array
%              is a list of points forming a broken line ([1 2 3] means
%              there will be a line from 1 to 2, one from 2 to 3.
%              only for display purposes
%   l        - [ dimSSpace x nFrame ] linear coefficients of the shape
%              basis in NRSFM
%   SBasis   - [ 3 x nPoint x dimSSpace ] Xiao's shape basis or
%              [ 3 x nPoint x (dimSSpace+1) ] Torresani's shape basis
%              (first shape has 1 as first coefficient, and the first
%              coefficient does not need to be specified in l)
%   misc     - whatever you want :)
%   type     - type of the data as generated by the generateToyAnimation
%   nBasis   - number of shape bases
%   nPoint   - number of feature points
%   nFrame   - number of frames
%   isProj   - flag indicating if the camera is projective
%
%
%
% IMPORTANT
%   for coding comfort, the automatic processes happens:
%     - when any element in l or SBasis is modified, S is generated
%       automatically and cannot be modified.
%     - if R and t are not empty and filled/updated, P is generated
%       automatically and cannot be modified.
%     - if K or KFull is modified, so is the other one
%
% An Animation object has the following methods
%   anim=generateSFromLSBasis( anim );
%   anim=generateCamFromRt( anim );
%   anim=generateWFromSRt( anim );
%   anim=generateSPCA( anim, nPCA );
%   anim=setFirstPRtToId( anim );
%   [ anim meanW ]=centerW( anim );
%   [ anim SimMin ]=sampleFrame( anim, nSamp, SimMin );
%
% USAGE
%  anim = Animation()
%
% INPUTS
%   nFrame  - the number of frames to consider
%   nPoint  - the number of points to consider
%   nBasis  - the number of shape bases if any
%   nDim    - the dimensionality of the points (3 for 3D, 2 for 2D)
%
% OUTPUTS
%  anim     - an Animation object
%
% EXAMPLE
%
% See also GENERATETOYANIMATION
%
% Vincent's Structure From Motion Toolbox      Version 3.0
% Copyright (C) 2009 Vincent Rabaud.  [vrabaud-at-cs.ucsd.edu]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the GPL [see external/gpl.txt]

% measurements
anim.W=[]; anim.mask=[];

% 3D / Object
anim.S=[];
anim.conn={}; % Cell of arrays of connectivities

% NRSFM
anim.l=[]; anim.SBasis=[];

% Camera
anim.P=[]; anim.K=[]; anim.R=[]; anim.t=[];

% Misc
anim.misc=[];

% Info
anim.isProj=false;
anim.type=-1;

% Quantities
anim.nBasis=0; anim.nPoint=0; anim.nFrame=0;

anim = class( anim, 'Animation');

% now, fill the quantities in anim according to varargin
if iscell(varargin)
  prmField = varargin(1:2:end); prmVal = varargin(2:2:end);
  for i=1:length(prmField)
    anim=subsasgn(anim,struct('type','.','subs',prmField{i}),prmVal{i});
  end
end
